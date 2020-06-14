
local INPUT = {}

INPUT.schema = {
  { id = 'lhs', name = "Left value", type = 'value', match = 'enum' },
  { id = 'rhs', name = "Right value", type = 'string' },
  { id = 'output', name = "Label", type = 'output' },
}

INPUT.type = 'boolean'

function INPUT.isValid(_, fieldvalues, _)
  return fieldvalues['lhs'] == fieldvalues['rhs']
end

return INPUT

