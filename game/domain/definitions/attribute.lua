
local round = require 'common.math' .round

local ATTR = {}

ATTR.BASE_SPD = 3
ATTR.INITIAL_UPGRADE = 100

ATTR.INFLUENCE = {
  DEF = {'COR', 'ARC'},
  EFC = {'ARC', 'ANI'},
  VIT = {'ANI', 'COR'}
}

function ATTR.EFFECTIVE_POWER(base, mod)
  return base * mod / 2
end

return ATTR

