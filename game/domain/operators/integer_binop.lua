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

function OP.process(_, fieldvalues)
  if fieldvalues.op == "+" then
    return fieldvalues.lhs + fieldvalues.rhs
  elseif fieldvalues.op == "-" then
    return fieldvalues.lhs - fieldvalues.rhs
  elseif fieldvalues.op == "*" then
    return fieldvalues.lhs * fieldvalues.rhs
  elseif fieldvalues.op == "/" then
    --Handle division by zero
    assert(fieldvalues.rhs ~= 0, "Tried to divide by zero")
    return math.floor(fieldvalues.lhs / fieldvalues.rhs)
  end

end

function OP.preview(_, fieldvalues)
  local lhs, rhs = fieldvalues['lhs'], fieldvalues['rhs']
  if type(lhs) == 'number' and type(rhs) == 'number' then
    return OP.process(_, fieldvalues)
  else
    return tostring(lhs) .. ' ' .. fieldvalues['op'] .. ' ' .. tostring(rhs)
  end
end

return OP
