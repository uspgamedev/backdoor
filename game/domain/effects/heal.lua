
local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'amount', name = "Heal amount", type = 'value', match = 'integer',
    range = {0} },
}

function FX.process (actor, fieldvalues)
  fieldvalues.target:heal(fieldvalues.amount or 2)
  coroutine.yield('report', {
    type = 'number_rise',
    number_type = 'heal',
    body = fieldvalues['target'],
    amount = fieldvalues['amount'],
  })
end

return FX

