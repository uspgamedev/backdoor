
local FX = {}

FX.schema = {
  { id = 'card_index', name = "Card position in hand", type = 'value',
    match = 'integer', range = {1} }, 
}

function FX.process (actor, sector, params)
  actor:consumeCard(params.card_index)
end

return FX

