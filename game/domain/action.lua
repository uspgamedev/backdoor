
local DIR = require 'domain.definitions.dir'

local action = {}

function action.IDLE(actor)
  return function()
    actor:spendTime(1)
  end
end

function action.MOVE(map, actor, dir_name)
  local dir = DIR[dir_name]
  assert(dir, ("Invalid direction '%s'"):format(dir_name))
  local i, j = unpack(map.bodies[actor:getBody()])
  local di, dj = unpack(dir)
  i, j = i+di, j+dj
  if map:valid(i, j) then
    return function()
      map:putBody(actor:getBody(), i, j)
      actor:spendTime(3)
    end
  else
    return action.IDLE(actor)
  end
end

return action
