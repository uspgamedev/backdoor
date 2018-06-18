
local ATTR = {}

ATTR.BASE_SPD = 3
ATTR.INITIAL_UPGRADE = 100

ATTR.INFLUENCE = {
  DEF = {'COR', 'ARC'},
  EFC = {'ARC', 'ANI'},
  VIT = {'ANI', 'COR'}
}

function ATTR.DMG(attr, base)
  local power = attr * base
  return power/4, 3*power/4
end

return ATTR

