
local tween = {}

function tween.start(from, to, pace)
  return function (dt)
    dt = dt or 1
    from = from + (to - from)/pace
    return from
  end
end

return tween

