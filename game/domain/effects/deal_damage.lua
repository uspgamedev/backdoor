
local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'amount', name = "Damage amount", type = 'value', match = 'integer',
    range = {0} },
}

function FX.process (actor, params)
  params.target:takeDamageFrom(params.amount or 2, actor)
end

return FX

