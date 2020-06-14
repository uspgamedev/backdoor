
local INPUT = {}

INPUT.schema = {
  { id = 'lhs', name = "Left value", type = 'value', match = 'integer' },
  { id = 'rhs', name = "Right value", type = 'value', match = 'integer' },
  { id = 'output', name = "Label", type = 'output' },
}

INPUT.type = 'boolean'

function INPUT.isValid(_, fieldvalues, _)
  return fieldvalues['lhs'] == fieldvalues['rhs']
end

return INPUT

