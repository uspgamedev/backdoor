
local DIR = require 'domain.definitions.dir'
local Action = require 'domain.action'

return function (actor, sector)
  local dir = DIR[DIR[love.math.random(4)]]
  local i, j = actor:getPos()
  local di, dj = unpack(dir)
  i, j = i+di, j+dj
  if sector:isValid(i, j) then
    return 'MOVE', { pos = {i,j} }
  else
    local body = sector:getBodyAt(i,j)
    if body then
      return 'PRIMARY', { target = {i,j} }
    else
      return 'IDLE', {}
    end
  end
end
