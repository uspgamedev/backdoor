
--- Get an attribute value of body

local DEFS = require 'domain.definitions'

local OP = {}

OP.schema = {
  { id = 'which', name = "Attribute", type = 'enum',
    options = DEFS.BODY_ATTRIBUTES },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'integer'

function OP.process(_, fieldvalues)
  return fieldvalues['which']:upper()
end

OP.preview = OP.process

return OP

