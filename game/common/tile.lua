
local TILE = {}

local abs = math.abs
local max = math.max

function TILE.dist(i1, j1, i2, j2)
  return max(abs(i1 - i2), abs(j1 - j2))
end

return TILE

