--Make a integer operation between two values

local OP = {}

OP.schema = {
  { id = 'lhs', name = "Operand 1", type = 'value', match = 'integer' },
  { id = 'op', name = "Operator", type = 'enum',
    options = {'+', '-', '*', '/'} },
  { id = 'rhs', name = "Operand 2", type = 'value', match = 'integer' },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'integer'

function OP.process(actor, sector, params)
  if params.op == "+" then
    return params.lhs + params.rhs
  elseif params.op == "-" then
    return params.lhs - params.rhs
  elseif params.op == "*" then
    return params.lhs * params.rhs
  elseif params.op == "/" then
    assert(params.rhs ~= 0, "Tried to divide by zero") --Handle division by zero
    return math.floor(params.lhs / params.rhs)
  end

end

return OP
