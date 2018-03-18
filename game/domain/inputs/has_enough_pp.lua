
local DEFS = require 'domain.definitions'
local INPUT = {}

INPUT.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'none'

function INPUT.isValid(actor, fieldvalues, value)
  return actor:getPP() >= DEFS.NEW_HAND_COST
end

return INPUT

