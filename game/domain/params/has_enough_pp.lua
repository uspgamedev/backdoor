
local DEFS = require 'domain.definitions'
local PARAM = {}

PARAM.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'none'

function PARAM.isValid(actor, parameter, value)
  return actor:getPP() >= DEFS.NEW_HAND_COST
end

return PARAM

