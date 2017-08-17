
local DIR = require 'domain.definitions.dir'

local FX = require "domain.effects"

----------

local action = {}


function action.IDLE(actor)
  return function()
    FX.spend_time{target = actor, amount = 1}
  end
end

function action.MOVE(map, actor, dir_name)
  local dir = DIR[dir_name]
  assert(dir, ("Invalid direction '%s'"):format(dir_name))
  local i, j = unpack(map.bodies[actor:getBody()])
  local di, dj = unpack(dir)
  i, j = i+di, j+dj
  if map:isValid(i, j) then
    return function()
      map:putBody(actor:getBody(), i, j)
      FX.spend_time{target = actor, amount = 3}
    end
  else
    return action.IDLE(actor)
  end
end

function action.PRIMARY(map, actor)
    local target = nil
    local i, j = actor:getPos()
    for y = i-1, i+1 do
        for x = j-1, j+1 do
            if (y ~= i or x ~= j) and map:isInside(y,x) and map.bodies[y][x] then
                target = map.bodies[y][x]
            end
        end
    end
    if target then
        return function()
            FX.damage{target = target, amount = 2}
            FX.spend_time{target = actor, amount = 3}
        end
    else
        return action.IDLE(actor)
    end

end

return action
