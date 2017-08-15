
local Map = Class {
  __includes = { ELEMENT }
}

local turnLoop

function Map:init(w, h)

  ELEMENT.init(self)

  self.w = w
  self.h = h

  self.tiles = {}
  self.bodies = {}
  self.actors = {}
  for i = 1, h do
    self.tiles[i] = {}
    self.bodies[i] = {}
    for j = 1, w do
      if love.math.random() > 0.2 then
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
function Map:putBody(body, i, j)
  assert(self:valid(i,j))
  -- Remove body from where it was vefore
  local oldmap = body:getMap() or self
  local oldbodies = oldmap.bodies
  local pos = oldmap.bodies[body] or {0,0}
  oldbodies[pos[1]][pos[2]] = false
  if self ~= oldmap then
    oldbodies[body] = nil
  end
  -- Actually put body at (i,j) in this map
  local bodies = self.bodies
  body:setMap(self.id)
  bodies[body] = pos
  bodies[i][j] = body
  pos[1], pos[2] = i, j
end

function Map:putActor(actor, i, j)
  self:putBody(actor:getBody(), i, j)
  return table.insert(self.actors, actor)
end

function Map:getBodyPos(body)
  return unpack(self.bodies[body])
end

function Map:getActorPos(actor)
  return self:getBodyPos(actor:getBody())
end

function Map:valid(i, j)
  return (i >= 1 and i <= self.h) and
         (j >= 1 and j <= self.w) and
         self.tiles[i][j] and not self.bodies[i][j]
end

function Map:randomNeighbor(i, j)
  local rand = love.math.random
  repeat
    local di, dj = 2*(1 - rand(2)) + 1, 2*(1 - rand(2)) + 1
    i = math.max(1, math.min(self.h, i+di))
    j = math.max(1, math.min(self.w, j+dj))
  until not self.bodies[i][j]
  return i, j
end

function turnLoop(self, ...)
  local yield = coroutine.yield
  while true do
    for _,actor in ipairs(self.actors) do
      actor:tick()
      if actor:ready() then
        actor:makeAction(self)
      end
    end
  end
end

function Map:playTurns(...)
  return assert(coroutine.resume(self.turnLoop, self, ...))
end

return Map
