
local math = setmetatable({}, {__index=math})

function math.round(n) return math.floor(n+.5) end

return math

