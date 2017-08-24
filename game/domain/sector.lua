
local DB = require 'database'
local SCHEMATICS = require 'definitions.schematics'
local TRANSFORMERS = require 'lux.pack' 'domain.transformers'
local SectorGrid = require 'domain.transformers.helpers.sectorgrid'

local Sector = Class {
  __includes = { ELEMENT }
}

local turnLoop

function Sector:init(sector_name)

  ELEMENT.init(self)

  local specs = DB.loadSpec("sector", sector_name)
  assert(specs, ("Database entry `sector.%s` not found."):format(sector_name))

  local general = specs.general
  local transformers = specs.transformers
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

  self.tiles = {}
  self.bodies = {}
  self.actors = {}
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
  -- A special tile where we can always remove things from...
  -- Because nothing is ever there!
  self.bodies[0] = { [0] = false }

  self.turnLoop = coroutine.create(turnLoop)

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


function Sector:randomNeighbor(i, j)
  local rand = love.math.random
  repeat
    local di, dj = 2*(1 - rand(2)) + 1, 2*(1 - rand(2)) + 1
    i = math.max(1, math.min(self.h, i+di))
    j = math.max(1, math.min(self.w, j+dj))
  until not self.bodies[i][j]
  return i, j
end

function turnLoop(self, ...)
  while true do
    for _,actor in ipairs(self.actors) do
      actor:tick()
      if actor:ready() then
        actor:makeAction(self)
      end
    end
  end
end

function Sector:playTurns(...)
  return select(2, assert(coroutine.resume(self.turnLoop, self, ...)))
end

return Sector
