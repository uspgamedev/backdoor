
local FX = {}

FX.schema = {
  { id = 'actor', name = "Actor", type = "value", match = 'actor' },
  { id = 'source', name = "Card source", type = 'enum',
    options = { 'HAND', 'PACK' } },
  { id = 'card-index', name = "Card position in pack", type = 'value',
    match = 'integer', range = {1} }, 
}

function FX.process (actor, fieldvalues)
  local self = fieldvalues['actor']
  local source = fieldvalues['source']
  if source == 'HAND' then
    self:removeHandCard(fieldvalues['card-index'])
  elseif source == 'PACK' then
    self:removePackCard(fieldvalues['card-index'])
  else
    return error("Unknown card source")
  end
end

return FX

