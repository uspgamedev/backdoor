
local FX = {}

FX.schema = {
  { id = 'amount', name = "Amount of cards", type = 'value', match = 'integer',
    range = {1} }, 
}

function FX.process (actor, sector, params)
  for i = 1, params.amount do
    actor:drawCard()
  end 
end

return FX
