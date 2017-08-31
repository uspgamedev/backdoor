
local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'amount', name = "Heal amount", type = 'value', match = 'integer',
    range = {0} },
}

function FX.process (actor, sector, params)
  params.target:heal(params.amount or 2)
end

return FX
