
--- Get an attribute value of user

local OP = {}

OP.schema = {
  { id = 'actor', name = "Actor", type = "value", match = 'actor' },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'body'

function OP.process(actor, fieldvalues)
  return actor:getBody()
end

return OP

