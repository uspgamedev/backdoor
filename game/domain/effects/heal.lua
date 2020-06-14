
local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'amount', name = "Amount", type = 'value', match = 'integer',
    range = {0,100} }
}

function FX.preview(_, fieldvalues)
  return ("heal %s hit points to %s")
         :format(fieldvalues['amount'], fieldvalues['target'])
end

function FX.process(_, fieldvalues)
  local target = fieldvalues['target']
  local amount = fieldvalues['amount']
  local effective_amount = target:heal(amount)
  coroutine.yield('report', {
    type = 'heal',
    body = target,
    amount = effective_amount,
  })
end

return FX
