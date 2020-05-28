local DB = require 'database'
local SCHEMATICS = require 'domain.definitions.schematics'
local ACTIONDEFS = require 'domain.definitions.action'
local TRIGGERS = require 'domain.definitions.triggers'
local RANDOM = require 'common.random'

local Actor = require 'domain.actor'
local Body  = require 'domain.body'
local Util  = require "steaming.util"
local Class = require "steaming.extra_libs.hump.class"

local GameElement = require 'domain.gameelement'

local Sector = Class {
  __includes = { GameElement }
}

local _turnLoop

local function _initBodies(w, h)
  local t = {}
  for i = 0, h do
    t[i] = {}
    for j = 0, w do
      t[i][j] = false
    end
  end
  return t
end

function Sector:init(spec_name, route)

  GameElement.init(self, 'sector', spec_name)

  self.w = 1
  self.h = 1

  self.route = route
  self.tiles = {{ false }}
  self.generated = false
  self.bodies = _initBodies(1,1)
  self.actors = {}
  self.exits = {}
  self.actors_queue = {}

  self.turnLoop = coroutine.create(_turnLoop)

end

function Sector:loadState(state)
  self:setId(state.id or self.id)
  self:setSubtype(self.spectype)
  self.exits = state.exits
  self.zone = GameElement('zone', state.zone)
  self.generated = state.generated
  if state.generated then
    self.tiles = state.tiles
    self.w = state.w or self.w
    self.h = state.h or self.h
    self.bodies = _initBodies(self.w, self.h)
    local bodies = {}
    for _,body_state in ipairs(state.bodies) do
      local body = Body(body_state.specname)
      body:loadState(body_state)
      bodies[body.id] = body_state
    end
    for _,actor_state in ipairs(state.actors) do
      local actor = Actor(actor_state.specname)
      actor:loadState(actor_state)
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
  state.id = self:getId()
  state.specname = self.specname
  state.zone = self.zone:getSpecName()
  state.exits = self.exits
  state.generated = self.generated
  state.tiles = self.tiles
  state.w = self.w
  state.h = self.h
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

function Sector:getRoute()
  return self.route
end

function Sector:getDimensions()
  return self.w, self.h
end

function Sector:getZone()
  return self.zone
end

function Sector:getTheme()
  return DB.loadSpec('theme', self:getZone():getSpec('theme'))
end

function Sector:getTileSet()
  return self:getTheme()['tileset']
end

function Sector:getZoneName()
  return self:getZone():getSpec('name')
end

function Sector:getDifficulty()
  return self:getZone():getSpec('difficulty')
end

function Sector:isGenerated()
  return self.generated
end

function Sector:getTile(i, j)
  return self.tiles[i][j]
end

--- Returns the exit with the given index
--  @param idx      The exit index (must be valid)
--  @param generate Flag indicating whether to generate the next sector over
--                  or not.
function Sector:getExit(id, generate)
  local exit = self.exits[id]
  assert(exit,
    ("No such exit: %s"):format(id))
  local result = {
    pos         = exit.pos,
    target_pos  = exit.target_pos
  }
  if not exit.target_pos and generate then
    self.route.linkSectorExit(self, id, result)
    result.target_pos = exit.target_pos
  end
  return result
end

--- Finds the exit at [i,j], if any
--  @param i        The i-position of the possible exit
--  @param j        The j-position of the possible exit
--  @param generate A flag passed on to Sector:getExit()
--  @return[1]      The target sector's id
--  @return[2]      The corresponding result of Sector:getExit
function Sector:findExit(i, j, generate)
  for id, exit in pairs(self.exits) do
    local di, dj = unpack(exit.pos)
    if di == i and dj == j then
      return id, self:getExit(id, generate)
    end
  end
  return false
end

function Sector:link(id, i, j)
  local exit = self.exits[id]
  exit.target_pos = {i, j}
end

--- Puts body at position (i.j), removing it from where it was before, wherever
--  that is!
function Sector:putBody(body, i, j)
  assert(self:isValid(i,j),
    ("Invalid position (%d,%d):"):format(i,j))
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

--- Removes the body at given position if it exists.
--  @return The associated actor if any
function Sector:removeBodyAt(i, j, body)

  local removed_actor

  --Checks if this body has an actor
  for k, actor in ipairs(self.actors) do
    if actor:getBody() ==  body then

      if actor:isPlayer() then
        self.route.die()
        coroutine.yield("playerDead")
      end

      removed_actor = table.remove(self.actors, k)

      break
    end
  end

  --Remove body from the sector
  self.bodies[i][j] = false
  self.bodies[body] = nil
  body:kill()

  return removed_actor

end

--- Remove all bodies with <=0 hp on the map
--  @return A table containing all removed actors
function Sector:removeDeadBodies()
  local dead_actor_list = {}
  local drop_points = {}

  for i = 1, self.h do
    for j = 1, self.w do

      local body = self:getBodyAt(i,j)

      if body and body:getHP() <= 0 then
        -- Trigger kill
        local killer_id = body:getKiller()
        local killer = Util.findId(killer_id)
        if killer then
          killer:getBody():triggerWidgets(TRIGGERS.ON_KILL)
        end
        -- Generate drops
        local drops_table = {}
        local drops = body:getDrops()
        for _,drop in ipairs(drops) do
          if RANDOM.generate(101)-1 < drop["droprate"] then
            table.insert(drops_table, drop["droptype"])
          end
        end
        -- Mark actor to remove
        local actor = self:removeBodyAt(i,j, body)
        if actor then
          table.insert(dead_actor_list, actor)
        end
        table.insert(drop_points, {i, j, drops_table})
      end

    end
  end

  return dead_actor_list, drop_points
end

function Sector:putActor(actor, i, j)
  local body = actor:getBody()
  local oldsector = body:getSector()
  if oldsector and oldsector ~= self then
    oldsector:removeActor(actor)
  end
  self:putBody(body, i, j)
  actor:purgeFov(self) --Update sector fov map to current sector dimensions
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

function Sector:iterateActors()
  return ipairs(self.actors)
end

function Sector:getActorFromBody(body)
  for _,actor in self:iterateActors() do
    if actor:getBody() == body then
      return actor
    end
  end
end

function Sector:getActorPos(actor)
  return self:getBodyPos(actor:getBody())
end

function Sector:isInside(i, j)
  return (i >= 1 and i <= self.h) and
         (j >= 1 and j <= self.w)
end

function Sector:isWalkable(i, j)
  return self:isInside(i,j) and
         (self.tiles[i][j] and self.tiles[i][j].type ~= SCHEMATICS.WALL)
end

function Sector:isValid(i, j)
  return self:isWalkable(i, j) and not self.bodies[i][j]
end

function Sector:randomValidTile()
  local rand = RANDOM.generate
  local i, j
  repeat
    i, j = rand(self.h), rand(self.w)
  until self:isValid(i, j)
  return i, j
end

function Sector:randomNeighbor(i, j, allow_bodies)
  local rand = RANDOM.generate
  repeat
    local di, dj = rand(-1, 1), rand(-1, 1)
    i = math.max(1, math.min(self.h, i+di))
    j = math.max(1, math.min(self.w, j+dj))
  until not (di == dj and di == 0) and
        allow_bodies or not self.bodies[i][j]
  return i, j
end

--- Check for dead bodies if any, and remove associated actors from the queue.
local function manageDeadBodiesAndUpdateActorsQueue(sector, actors_queue)
  local dead_actor_list, drop_points = sector:removeDeadBodies()
  for _, dead_actor in ipairs(dead_actor_list) do
    for i, act in ipairs(actors_queue) do
      if dead_actor == act then
        table.remove(actors_queue, i)
        break
      end
    end
    sector:getRoute().getBehaviors().removeAI(dead_actor)
    dead_actor:kill()
  end
  for _,drop_point in ipairs(drop_points) do
    sector:spreadDrops(unpack(drop_point))
  end
end

function Sector:spreadDrops(i, j, drops)
  local ti, tj
  local tile
  local new_drops = {}
  for _,drop in ipairs(drops) do
    repeat
      ti, tj = self:randomNeighbor(i, j, true)
    until self:isWalkable(ti, tj)
    tile = self.tiles[ti][tj]
    table.insert(tile.drops, drop)
    table.insert(new_drops, {ti, tj, #tile.drops})
  end
  coroutine.yield('report', {
    type = 'drop_spread',
    drops = new_drops,
    origin = {i, j}
  })

end

function _turnLoop(self)
  local actors_queue = self.actors_queue
  while true do

    for body in pairs(self.bodies) do
      if type(body) == 'table' then
        body:tick()
      end
    end

    --Initialize actor queue
    for _,actor in ipairs(self.actors) do
      actor:tick()
      actor:grabDrops(self:getTile(actor:getPos()))
      actor:updateFov(self)
      table.insert(actors_queue, actor)
    end

    manageDeadBodiesAndUpdateActorsQueue(self, actors_queue)

    while not Util.tableEmpty(actors_queue) do
      local actor = table.remove(actors_queue, 1)

      while actor:ready() do
        actor:beginTurn()
        actor:makeAction()
        manageDeadBodiesAndUpdateActorsQueue(self, actors_queue)
        actor:endTurn()
      end

      if actor:isPlayer() and actor:getBody():getSector() ~= self then
        coroutine.yield('changeSector')
        break
      end
    end

  end
end

function Sector:previewTurns(n, half_exhaustion, filter)
  if #self.actors <= 1 then
    return {}
  end
  -- find pertinent actors and order
  local actors = {}
  local count = 0
  local begin = #self.actors + 1
  if #self.actors_queue > 0 then
    local current = self.actors_queue[1]
    for i, actor in ipairs(self.actors) do
      if actor == current then
        begin = i
        break
      end
    end
    for i = begin, #self.actors do
      local actor = self.actors[i]
      if filter(actor) then
        count = count + 1
        actors[count] = actor
      end
    end
  end
  for i = 1, begin - 1 do
    local actor = self.actors[i]
    if filter(actor) then
      count = count + 1
      actors[count] = actor
    end
  end
  -- Calculate ticks to the next n turns of each actor
  local ticks = {}
  for i, actor in ipairs(actors) do
    ticks[i] = {}
    for k = 1, 2*n do
      local exhaustion = ACTIONDEFS.FULL_EXHAUSTION
      if i == count and half_exhaustion then
        exhaustion = ACTIONDEFS.HALF_EXHAUSTION
      end
      local remaining = ((k - 1) * ACTIONDEFS.FULL_EXHAUSTION + exhaustion)
                      * ACTIONDEFS.EXHAUSTION_UNIT
                      - actor:getEnergy()
      ticks[i][k] = remaining / actor:getSPD()
    end
    -- Ignore if current active turn
    if i == count then
      table.remove(ticks[i], 1)
    end
  end
  -- Preview turn order
  local turns = {}
  local i = 1
  local round = 0
  while i <= n do
    for k, actor in ipairs(actors) do
      if ticks[k][1] and ticks[k][1] <= round then
        turns[i] = actor
        i = i + 1
        table.remove(ticks[k], 1)
      end
    end
    round = round + 1
  end
  for k = n+1, #turns do
    turns[k] = nil
  end
  return turns
end

--- Plays turn coroutine.
--  Any erros in it are propagated with the appropriate stacktrace.
function Sector:playTurns(...)
  local result = table.pack(coroutine.resume(self.turnLoop, self, ...))
  local ok, err = unpack(result)
  if not ok then
    return error(debug.traceback(self.turnLoop, err))
  else
    return unpack(result, 2)
  end
end



return Sector
