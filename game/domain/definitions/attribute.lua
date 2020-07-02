
local ATTR = {}

ATTR.BASE_SPD = 10
ATTR.INITIAL_UPGRADE = 100

ATTR.INFLUENCE = {
  SPD = {'COR', 'ARC'},
  SKL = {'ARC', 'ANI'},
  VIT = {'ANI', 'COR'}
}

function ATTR.POWER_LEVEL(upgrades)
  local lvl = 0
  for _,value in pairs(upgrades) do
    lvl = value + lvl
  end
  return lvl / ATTR.INITIAL_UPGRADE / 3
end

function ATTR.EFFECTIVE_POWER(base, attr, mod)
  return math.max(1, math.floor(base + attr * mod / 100))
end

return ATTR

