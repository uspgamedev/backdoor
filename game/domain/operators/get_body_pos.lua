
--- Get body at given position

local OP = {}

OP.schema = {
  { id = 'body', name = "Body", type = 'value', match = 'body' },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'pos'

function OP.process(actor, params)
  return { params['body']:getPos() }
end

return OP

