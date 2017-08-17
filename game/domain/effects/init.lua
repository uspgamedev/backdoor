
local EFFECT = {}

local meta = {}

function meta:__index(name)
  return require("domain.effects." .. name)
end

return setmetatable(EFFECT, meta)
