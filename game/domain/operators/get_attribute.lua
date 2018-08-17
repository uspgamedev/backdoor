
--- Get an attribute value of user

local DEFS = require 'domain.definitions'

local OP = {}

OP.schema = {
  { id = 'which', name = "Attribute", type = 'enum',
    options = DEFS.PRIMARY_ATTRIBUTES },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'integer'

function OP.process(actor, fieldvalues)
  return actor["get"..fieldvalues.which](actor)
end

OP.preview = OP.process

return OP

