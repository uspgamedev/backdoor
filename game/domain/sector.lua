
local DB = require 'database'
local SCHEMATICS = require 'domain.definitions.schematics'
local TRANSFORMERS = require 'lux.pack' 'domain.transformers'
local COLORS = require 'domain.definitions.colors'

local Actor = require 'domain.actor'
local Body = require 'domain.body'

local SectorGrid = require 'domain.transformers.helpers.sectorgrid'
local GameElement = require 'domain.gameelement'

local Sector = Class {
  __includes = { GameElement }
}

local _turnLoop

local function _resize(w, h)
  local t = {}
  for i = 1, h do
    t[i] = {}
    for j = 1, w do
      t[i][j] = false
    end
  end
  t[0] = { [0]=false }
  return t
end

function Sector:init(spec_name)

  GameElement.init(self, 'sector', spec_name)

  self.w = 1
  self.h = 1

  self.tiles = {{ false }}
  self.bodies = {}
  self.actors = {}
  self.exits = {}
  self.actors_queue = {}

  -- A special tile where we can always remove things from...
  -- Because nothing is ever there!
  self.bodies[0] = { [0] = false }

  self.turnLoop = coroutine.create(_turnLoop)

end

function Sector:loadState(state, register)
  self.w = state.w or self.w
  self.h = state.h or self.h
  self.id = state.id
  self.exits = state.exits
  self:setId(state.id)
  if state.tiles then
    local grid = SectorGrid:from(state.tiles)
    self:makeTiles(grid)
    --self.bodies = _resize(self.w, self.h)
    local bodies = {}
    for _,body_state in ipairs(state.bodies) do
      local body = Body(body_state.specname)
      body:loadState(body_state)
      register(body)
      bodies[body.id] = body_state
    end
    for _,actor_state in ipairs(state.actors) do
      local actor = Actor(actor_state.specname)
      actor:loadState(actor_state)
      register(actor)
      local body_id = actor.body_id
      local body_state = bodies[body_id]
      local i, j = body_state.i, body_state.j
      bodies[body_id] = nil
      self:putActor(actor, i, j)
    end
    for id, body_state in pairs(bodies) do
      local i, j = body_state.i, body_state.j
      local body = Util.findId(id)
      self:putBody(body, i, j)
    end
  end
end

function Sector:saveState()
  local state = {}
  state.specname = self.specname
  state.w = self.w
  state.h = self.h
  state.id = self.id
  state.exits = self.exits
  state.tiles = self.tiles
  state.actors = {}
  state.bodies = {}
  for _,actor in ipairs(self.actors) do
    local actor_state = actor:saveState()
    table.insert(state.actors, actor_state)
  end
  for body, body_pos in pairs(self.bodies) do
    if not tonumber(body) then
      local i, j = body_pos[1], body_pos[2]
      local body_state = body:saveState()
      body_state.i = i
      body_state.j = j
      table.insert(state.bodies, body_state)
    end
  end
  return state
end

function Sector:generate()

  local transformers = self:getSpec('transformers')

  -- load sector's specs
  local base = {}

  -- sector grid generation
  for _, transformer in ipairs(transformers) do
    base = TRANSFORMERS[transformer.typename].process(base, transformer)
  end

  self:makeTiles(base.grid)
  self:makeExits(base.exits)
end

function Sector:makeTiles(grid)
  self.w, self.h = grid.getDim()
  for i = 1, self.h do
    self.tiles[i] = {}
    self.bodies[i] = {}
    for j = 1, self.w do
      local tile = false
      local tile_type = grid.get(j, i)
      if grid.get(j, i) == SCHEMATICS.FLOOR then
        if (i+j) % 2 == 0 then
          tile = { unpack(COLORS.FLOOR1) }
        else
          tile = { unpack(COLORS.FLOOR2) }
        end
      elseif grid.get(j, i) == SCHEMATICS.EXIT then
        tile = { unpack(COLORS.EXIT) }
      end
      if tile then tile.type = tile_type end
      self.tiles[i][j] = tile
      self.bodies[i][j] = false
    end
  end
end

function Sector:makeExits(exits)
  local generated_exits = exits or {}
  for i, exit in ipairs(generated_exits) do
    self.exits[i] = {
      pos = exit.pos,
      target_specname = exit.target_specname,
      target_id = false,
    }
  end
end

function Sector:getExit(idx)
  local exit = self.exits[idx]
  assert(exit,
    ("No exit of index: %d\n%s"):format(idx, debug.traceback()))
  return {
    pos        = exit.pos,
    specname   = exit.target_specname,
    id         = exit.target_id,
    target_pos = exit.target_pos,
  }
end

function Sector:findExit(i, j)
  -- returns: int: idx, table: target
  for idx, exit in ipairs(self.exits) do
    local di, dj = unpack(exit.pos)
    if di == i and dj == j then
      return idx, self:getExit(idx)
    end
  end
  return false
end

function Sector:link(idx, sector_id, i, j)
  local exit = self.exits[idx]
  exit.target_id = sector_id
  exit.target_pos = {i, j}
end

--- Puts body at position (i.j), removing it from where it was before, wherever
--  that is!
function Sector:putBody(body, i, j)
  assert(self:isValid(i,j),
    ("Invalid position (%d,%d):"):format(i,j) .. debug.traceback())
  -- Remove body from where it was vefore
  local oldsector = body:getSector() or self
  local oldbodies = oldsector.bodies
  local pos = oldsector.bodies[body] or {0,0}
  oldbodies[pos[1]][pos[2]] = false
  if self ~= oldsector then
    oldbodies[body] = nil
  end
  -- Actually put body at (i,j) in this sector
  local bodies = self.bodies
  body:setSector(self.id)
  bodies[body] = pos
  bodies[i][j] = body
  pos[1], pos[2] = i, j
end

function Sector:getBodyAt(i, j)
  return self:isInside(i,j) and self.bodies[i][j] or nil
end

--Removes the body at given position if it exists. Returns the associated actor if any
function Sector:removeBodyAt(i, j, body)

  local removed_actor

  --Checks if this body has an actor
  for i, actor in ipairs(self.actors) do
    if actor:getBody() ==  body then

      if actor:getSpec("behavior") == "player" then
        coroutine.yield("playerDead")
      end

      removed_actor = table.remove(self.actors, i)

      break
    end
  end

  --Remove body from the sector
  self.bodies[i][j] = false
  self.bodies[body] = nil
  body:kill()

  return removed_actor

end

--Remove all bodies with <=0 hp on the map and return a table containing all removed actors
function Sector:removeDeadBodies()
  local dead_actor_list = {}

  for i = 1, self.h do
    for j = 1, self.w do

      local body = self:getBodyAt(i,j)

      if body and body:getHP() <= 0 then
        local actor = self:removeBodyAt(i,j, body)
        if actor then
          table.insert(dead_actor_list,actor)
        end
      end

    end
  end

  return dead_actor_list
end

function Sector:putActor(actor, i, j)
  local body = actor:getBody()
  local oldsector = body:getSector()
  if oldsector and oldsector ~= self then
    oldsector:removeActor(actor)
  end
  self:putBody(body, i, j)
  return table.insert(self.actors, actor)
end

function Sector:removeActor(removed_actor)
  local idx
  for i, actor in ipairs(self.actors) do
    if actor == removed_actor then idx = i break end
  end
  table.remove(self.actors, idx)
  for i, actor in ipairs(self.actors_queue) do
    if actor == removed_actor then idx = i break end
  end
  table.remove(self.actors_queue, idx)
end

function Sector:getBodyPos(body)
  return unpack(self.bodies[body])
end

function Sector:getActorPos(actor)
  return self:getBodyPos(actor:getBody())
end

function Sector:isInside(i, j)
  return (i >= 1 and i <= self.h) and
  (j >= 1 and j <= self.w)
end

function Sector:isValid(i, j)
  return self:isInside(i,j) and
  self.tiles[i][j] and not self.bodies[i][j]
end

function Sector:randomValidTile()
  local rand = love.math.random
  local i, j
  repeat
    i, j = rand(self.h), rand(self.w)
  until self:isValid(i, j)
  return i, j
end

function Sector:randomNeighbor(i, j)
  local rand = love.math.random
  repeat
    local di, dj = 2*(1 - rand(2)) + 1, 2*(1 - rand(2)) + 1
    i = math.max(1, math.min(self.h, i+di))
    j = math.max(1, math.min(self.w, j+dj))
  until not self.bodies[i][j]
  return i, j
end

--Check for dead bodies if any, and remove associated actors from the queue
local function manageDeadBodiesAndUpdateActorsQueue(sector, actors_queue)
  local dead_actor_list = sector:removeDeadBodies()
  for _, dead_actor in ipairs(dead_actor_list) do
    for i, act in ipairs(actors_queue) do
      if dead_actor == act then
        table.remove(actors_queue, i)
        break
      end
    end
    dead_actor:kill()
  end
end


function _turnLoop(self, ...)
  local actors_queue = self.actors_queue
  while true do

    --Initialize actor queue
    for _,actor in ipairs(self.actors) do
      table.insert(actors_queue,actor)
    end

    while(not Util.tableEmpty(actors_queue)) do
      actor = table.remove(actors_queue)

      actor:tick()
      if actor:ready() then
        actor:makeAction(self)
      end

      manageDeadBodiesAndUpdateActorsQueue(self, actors_queue)
    end

  end
end

function Sector:playTurns(...)
  return select(2, assert(coroutine.resume(self.turnLoop, self, ...)))
end



return Sector
