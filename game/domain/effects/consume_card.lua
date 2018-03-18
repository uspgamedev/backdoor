
local FX = {}

FX.schema = {
  { id = 'card', name = "Consumed card", type = 'value', match = 'card' }, 
}

function FX.process (actor, fieldvalues)
  actor:consumeCard(fieldvalues['card'])
end

return FX

