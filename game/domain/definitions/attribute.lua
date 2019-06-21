
local round = require 'common.math' .round

local ATTR = {}

ATTR.BASE_SPD = 10
ATTR.INITIAL_UPGRADE = 100

ATTR.INFLUENCE = {
  DEF = {'COR', 'ARC'},
  EFC = {'ARC', 'ANI'},
  VIT = {'ANI', 'COR'}
}

function ATTR.EFFECTIVE_POWER(base, mod)
  return round(base * mod / 2)
end

return ATTR

