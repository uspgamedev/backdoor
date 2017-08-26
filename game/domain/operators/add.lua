
local OP = {}

OP.schema = {
  { id = 'lhs', name = "Operand 1", type = 'value/integer' },
  { id = 'rhs', name = "Operand 2", type = 'value/integer' },
  { id = 'output', name = "Label", type = 'value/output' }
}

OP.type = 'integer'

function OP.process(actor, sector, params)
  return params.lhs + params.rhs
end

return OP

