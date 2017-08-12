
local action = require 'domain.action'

return function (map, actor)
  local i, j = unpack(map.bodies[actor.body])
  i, j = map:randomNeighbor(i, j)
  return action.MOVE(map, actor, i, j)
end
