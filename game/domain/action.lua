
local action = {}

function action.IDLE(actor)
  return function()
    actor:spendTime(1)
  end
end

function action.MOVE(map, actor, i, j)
  if map:valid(i, j) then
    return function()
      map:putBody(actor.body, i, j)
      actor:spendTime(3)
    end
  else
    return action.IDLE(actor)
  end
end

return action
