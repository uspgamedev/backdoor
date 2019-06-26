
local DEFS = require 'domain.definitions'

return {
  { id = 'cost', name = "Cost", type = 'range', min = 0,
    max = DEFS.ACTION.MAX_FOCUS },
  { id = 'ability', name = "Activated Ability", type = 'ability' },
}

