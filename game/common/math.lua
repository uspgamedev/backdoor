
local math = setmetatable({}, {__index=math})

function math.round(n,...)
  if n then
    return math.floor(n+.5), math.round(...)
  end
end

return math

