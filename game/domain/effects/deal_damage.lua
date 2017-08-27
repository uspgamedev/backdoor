
local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'amount', name = "Damage amount", type = 'value', match = 'integer',
    range = {0} },
}

function FX.process (actor, sector, params)
  params.target:takeDamage(params.amount or 2)
end

return FX

