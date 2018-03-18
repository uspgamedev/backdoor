
local DEFS = require 'domain.definitions'
local INPUT = {}

INPUT.schema = {
  { id = 'card', name = "Card", type = 'value', match = 'card' },
  { id = 'attribute', name = "Attribute", type = 'enum',
    options = DEFS.PRIMARY_ATTRIBUTES },
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'boolean'

function INPUT.isValid(actor, fieldvalues, value)
  return fieldvalues['card']:getRelatedAttr() == fieldvalues['attribute']
end

return INPUT

