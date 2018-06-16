
local ATTR = {}

ATTR.BASE_SPD = 3
ATTR.INITIAL_UPGRADE = 100

ATTR.INFLUENCE = {
  DEF = {'COR', 'ARC'},
  EFC = {'ARC', 'ANI'},
  VIT = {'ANI', 'COR'}
}

function ATTR.MAXDMG(attr, base)
  return attr * base
end

return ATTR

