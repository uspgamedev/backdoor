
local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'amount', name = "Heal amount", type = 'value', match = 'integer',
    range = {0} },
}

function FX.process (actor, params)
  params.target:heal(params.amount or 2)
  coroutine.yield('report', {
    type = 'healed',
    body = params['target'],
    amount = params['amount'],
  })
end

return FX

