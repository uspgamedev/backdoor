
local DB = require 'database'
local SCHEMATICS = require 'definitions.schematics'
local TRANSFORMERS = require 'lux.pack' 'domain.transformers'

local SectorGrid = require 'domain.transformers.helpers.sectorgrid'
local GameElement = require 'domain.gameelement'

local Sector = Class {
  __includes = { GameElement }
}

local turnLoop

function Sector:init(spec_name)

  GameElement.init(self, 'sector', spec_name)

  self.w = 1
  self.h = 1

  self.tiles = {{ false }}
  self.bodies = {}
  self.actors = {}

  -- A special tile where we can always remove things from...
  -- Because nothing is ever there!
  self.bodies[0] = { [0] = false }

  self.turnLoop = coroutine.create(turnLoop)

end

function Sector:generate()

  local general = self:getSpec('general')
  local transformers = self:getSpec('transformers')
  local w, h = general.width, general.height

  -- load sector's specs
  self.base = SectorGrid(w, h, general.mw, general.mh)

  self.w = w
  self.h = h

  -- sector grid generation
  for _, transformer in ipairs(transformers) do
    local transformer_name = transformer.name
    local transformer_params = transformer.params
    TRANSFORMERS[transformer_name](self.base, transformer_params)
  end

  for i = 1, h do
    self.tiles[i] = {}
    self.bodies[i] = {}
    for j = 1, w do
      if self.base.get(j, i) == SCHEMATICS.FLOOR then
        self.tiles[i][j] = {25, 73, 95 + (i+j)%2*20}
      else
        self.tiles[i][j] = false
      end
      self.bodies[i][j] = false
    end
  end

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

      --FIXME: If player dies the game just closes. Change this in the future
      if actor:getSpec("behavior") == "player" then
          os.exit(0)
      end

      removed_actor = table.remove(self.actors, i)

      break
    end
  end

  --Remove body from the sector
  self.bodies[i][j] = false

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
  self:putBody(actor:getBody(), i, j)
  return table.insert(self.actors, actor)
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
    end
end


function turnLoop(self, ...)
  local actors_queue = {}
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
