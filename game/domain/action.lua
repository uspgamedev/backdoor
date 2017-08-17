
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
    return function()
        local _,target = coroutine.yield(actor, "pick_target",
        {
          pos = {actor:getPos()},
          valid_position_func = function(i, j)
                                return map:isInside(i,j) and map.bodies[i][j]
                            end
        })
        if target then
            local i,j = unpack(target)
            target = map.bodies[i][j]
            FX.damage{target = target, amount = 2}
            FX.spend_time{target = actor, amount = 3}
        else
            coroutine.yield(actor)
        end
    end

end

return action
