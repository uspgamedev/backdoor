
local FX = {}

FX.schema = {
  { id = 'card-index', name = "Card position in hand", type = 'value',
    match = 'integer', range = {1} }, 
}

function FX.process (actor, sector, params)
  actor:removeHandCard(params['card-index'])
end

return FX

