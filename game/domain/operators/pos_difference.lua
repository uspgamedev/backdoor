
--- Get translated position from pos+dir

local OP = {}

OP.schema = {
  { id = 'from', name = "Position From", type = 'value', match = 'pos' },
  { id = 'to', name = "Position To", type = 'value', match = 'pos' },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'dir'

function OP.process(actor, fieldvalues)
  local from = fieldvalues['from']
  local to = fieldvalues['to']
  return { to[1]-from[1], to[2]-from[2] }
end

return OP

