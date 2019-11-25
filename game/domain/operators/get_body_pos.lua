
--- Get body at given position

local OP = {}

OP.schema = {
  { id = 'body', name = "Body", type = 'value', match = 'body' },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'pos'

function OP.process(_, fieldvalues)
  return { fieldvalues['body']:getPos() }
end

function OP.preview(_, fieldvalues)
  return ("%s's position"):format(fieldvalues['body'])
end

return OP
