
local PARAM = {}

PARAM.schema = {
  { id = 'lhs', name = "Operand 1", type = 'value', match = 'card' },
  { id = 'rhs', name = "Operand 2", type = 'value', match = 'card' },
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'boolean'

function PARAM.isValid(sector, actor, parameter, value)
  local lhs, rhs = parameter['lhs'], parameter['rhs']
  local op = parameter['op']
  return lhs == rhs
end

return PARAM

