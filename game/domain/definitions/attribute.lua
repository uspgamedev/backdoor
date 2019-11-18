
local ATTR = {}

ATTR.BASE_SPD = 10
ATTR.INITIAL_UPGRADE = 100

ATTR.INFLUENCE = {
  SKL = {'COR', 'ARC'},
  SPD = {'ARC', 'ANI'},
  VIT = {'ANI', 'COR'}
}

function ATTR.EFFECTIVE_POWER(base, attr, mod)
  return math.max(1, math.floor(base + attr * mod / 100))
end

return ATTR

