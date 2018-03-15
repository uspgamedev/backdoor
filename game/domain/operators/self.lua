
--- Get controlled actor

local OP = {}

OP.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'actor'

function OP.process(actor, fieldvalues)
  return actor
end

return OP

