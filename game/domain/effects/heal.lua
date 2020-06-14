
local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'value', name = "value", type = 'value', match = 'integer',
    range = {0,100} }
}

function FX.preview(_, fieldvalues)
  return ("heal %s hit points to %s")
         :format(fieldvalues['value'], fieldvalues['target'])
end

function FX.process(_, fieldvalues)
  local target = fieldvalues['target']
  local value = fieldvalues['value']
  local effective_value = target:heal(value)
  coroutine.yield('report', {
    type = 'heal',
    body = target,
    amount = effective_value,
  })
end

return FX
