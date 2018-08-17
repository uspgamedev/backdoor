
local tween = {}

function tween.start(from, to, pace)
  return function (dt)
    dt = dt or 1
    local step = (to - from)/pace
    if step*step > 0.01 then
      from = from + step * dt
    else
      from = to
    end
    return from
  end
end

return tween
