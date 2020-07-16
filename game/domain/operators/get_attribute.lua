
--- Get an attribute value of user

local DEFS = require 'domain.definitions'

local OP = {}

OP.schema = {
  { id = 'which', name = "Attribute", type = 'enum',
    options = DEFS.ALL_ATTRIBUTES },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'integer'

function OP.process(actor, fieldvalues)
  return actor["get"..fieldvalues.which](actor)
end

function OP.preview(_, fieldvalues)
  return fieldvalues['which']:upper()
end

return OP

