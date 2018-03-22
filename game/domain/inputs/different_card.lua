
local INPUT = {}

INPUT.schema = {
  { id = 'lhs', name = "Operand 1", type = 'value', match = 'card' },
  { id = 'rhs', name = "Operand 2", type = 'value', match = 'card' },
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'boolean'

function INPUT.isValid(actor, fieldvalues, value)
  local lhs, rhs = fieldvalues['lhs'], fieldvalues['rhs']
  local op = fieldvalues['op']
  return lhs ~= rhs
end

return INPUT

