
local DEFS = require 'domain.definitions'
local PARAM = {}

PARAM.schema = {
  { id = 'card', name = "Card", type = 'value', match = 'card' },
  { id = 'attribute', name = "Attribute", type = 'enum',
    options = DEFS.PRIMARY_ATTRIBUTES },
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'boolean'

function PARAM.isValid(actor, parameter, value)
  return parameter['card']:getRelatedAttr() == parameter['attribute']
end

return PARAM

