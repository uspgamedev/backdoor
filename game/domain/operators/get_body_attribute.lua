
--- Get an attribute value of body

local DEFS = require 'domain.definitions'

local OP = {}

OP.schema = {
  { id = 'which', name = "Attribute", type = 'enum',
    options = DEFS.BODY_ATTRIBUTES },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'integer'

function OP.process(actor, fieldvalues)
  local body = actor:getBody()
  return body["get"..fieldvalues.which](body)
end

OP.preview = OP.process

return OP

