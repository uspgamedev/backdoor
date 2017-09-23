
--- Get actor's card from pack

local OP = {}

OP.schema = {
  { id = 'output', name = "Label", type = 'output' },
  { id = 'actor', name = "Actor", type = "value", match = 'actor' },
  { id = 'source', name = "Card source", type = 'enum',
    options = { 'HAND', 'PACK' } },
  { id = 'card-index', name = "Position in Pack", type = "value",
    match = 'integer', range = {1} }
}

OP.type = 'card'

function OP.process(actor, sector, params)
  local self = params['actor']
  local index = params['card-index']
  local source = params['source']
  if source == 'HAND' then
    return self:getHandCard(index)
  elseif source == 'PACK' then
    return self:getPackCard(index)
  else
    return error("Unknown card source")
  end
end

return OP

