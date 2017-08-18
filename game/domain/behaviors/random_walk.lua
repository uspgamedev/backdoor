
local DIR = require 'domain.definitions.dir'
local Action = require 'domain.action'

return function (actor, map)
  local dir = DIR[DIR[love.math.random(4)]]
  local i, j = actor:getPos()
  local di, dj = unpack(dir)
  i, j = i+di, j+dj
  if map:isValid(i, j) then
    return 'MOVE', {{i,j}}
  else
    local body = map:getBodyAt(i,j)
    if body then
      return 'PRIMARY', {body}
    else
      return 'IDLE', {}
    end
  end
end

