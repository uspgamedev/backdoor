
local TILE = {}

local abs = math.abs

function TILE.dist(i1, j1, i2, j2)
  return abs(i1 - i2) + abs(j1 - j2)
end

return TILE

