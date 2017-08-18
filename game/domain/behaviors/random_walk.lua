
local DIR = require 'domain.definitions.dir'
local Action = require 'domain.action'

return function (actor, map)
  local dir = DIR[DIR[love.math.random(4)]]
  local i, j = actor:getPos()
  local di, dj = unpack(dir)
  i, j = i+di, j+dj
  if map:isValid(i, j) then
    return Action('MOVE', actor, map, {{i,j}})
  else
    return Action('IDLE', actor, map, {})
  end
end
