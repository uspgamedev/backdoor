
local DIR = require 'domain.definitions.dir'
local action = require 'domain.action'

return function (actor, map)
  return action.MOVE(map, actor, DIR[love.math.random(4)])
end
