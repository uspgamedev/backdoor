
local FX = {}

FX.schema = {
  { id = 'card', name = "Consumed card", type = 'value', match = 'card' }, 
}

function FX.process (actor, sector, params)
  actor:consumeCard(params['card'])
end

return FX

