
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
      self.tiles[i][j] = {25, 73, 127}
      self.bodies[i][j] = false
    end
  end

  self.turnLoop = coroutine.create(turnLoop)

end

function Map:putBody(body, i, j)
  assert(i >= 1 and i <= self.h)
  assert(j >= 1 and j <= self.w)
  local bodies = self.bodies
  assert(not bodies[i][j])
  local pos = bodies[body] if pos then
    bodies[pos[1]][pos[2]] = false
  else
    pos = {}
    bodies[body] = pos
  end
  bodies[i][j] = body
  pos[1], pos[2] = i, j
end

function Map:putActor(actor, i, j)
  self:putBody(actor.body, i, j)
  return table.insert(self.actors, actor)
end

function Map:randomNeighbor(i, j)
  local rand = love.math.random
  local di, dj = 2*(1 - rand(2)) + 1, 2*(1 - rand(2)) + 1
  i = math.max(1, math.min(self.h, i+di))
  j = math.max(1, math.min(self.w, j+dj))
  return i, j
end

function turnLoop(self)
  local yield = coroutine.yield
  while true do
    for i = 1, 10 do
      for _,actor in ipairs(self.actors) do
        actor:tick()
        if actor:ready() then
          while not actor:hasAction() do
            yield()
          end
          local action = actor:getAction()
          if action == 'walk' then
            local i, j = self:randomNeighbor(unpack(self.bodies[actor.body]))
            self:putBody(actor.body, i, j)
            actor:spendTime(3)
          end
        end
      end
    end
    yield()
  end
end

function Map:playTurns()
  return assert(coroutine.resume(self.turnLoop, self))
end

return Map
