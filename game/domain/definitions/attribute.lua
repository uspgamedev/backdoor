
local ATTR = {}

ATTR.BASE_SPD = 10
ATTR.INITIAL_UPGRADE = 100

ATTR.NAME = {
  COR = 'corporis',
  ARC = 'arcana',
  ANI = 'anima'
}

ATTR.INFLUENCE = {
  SPD = {'COR', 'ARC'},
  SKL = {'ARC', 'ANI'},
  VIT = {'ANI', 'COR'}
}

ATTR.MOD = {
  'half', 'full', 'double',
  half = 0.5,
  full = 1.0,
  double = 2.0
}

ATTR.MOD_DESCRIPTION = {
  half = "+0.5 per ",
  full = "+1 per ",
  double = "+2 per "
}

function ATTR.POWER_LEVEL(upgrades)
  local lvl = 0
  for _,value in pairs(upgrades) do
    lvl = value + lvl
  end
  return lvl / ATTR.INITIAL_UPGRADE / 3
end

function ATTR.EFFECTIVE_MOD(attr, mod)
  return math.floor(attr * ATTR.MOD[mod])
end

function ATTR.EFFECTIVE_POWER(base, attr, mod)
  return math.max(1, base + ATTR.EFFECTIVE_MOD(attr, mod))
end

return ATTR

