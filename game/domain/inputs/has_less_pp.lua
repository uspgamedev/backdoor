
local DEFS = require 'domain.definitions'
local INPUT = {}

INPUT.schema = {
  { id = 'amount', name = "Amount", type = 'value', match = 'integer' },
  { id = 'output', name = "Label", type = 'output' },
}

INPUT.type = 'none'

function INPUT.isValid(actor, fieldvalues, value)
  return actor:getPP() < fieldvalues['amount']
end

return INPUT

