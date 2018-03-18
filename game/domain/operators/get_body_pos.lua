
--- Get body at given position

local OP = {}

OP.schema = {
  { id = 'body', name = "Body", type = 'value', match = 'body' },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'pos'

function OP.process(actor, fieldvalues)
  return { fieldvalues['body']:getPos() }
end

return OP
