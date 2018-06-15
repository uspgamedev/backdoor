
local ACTION = require 'domain.definitions.action'
local ATTR = {}

ATTR.BASE_SPD = ACTION.CYCLE_UNIT
ATTR.INITIAL_UPGRADE = 100

ATTR.INFLUENCE = {
  DEF = {'COR', 'ARC'},
  EFC = {'ARC', 'ANI'},
  VIT = {'ANI', 'COR'}
}

return ATTR

