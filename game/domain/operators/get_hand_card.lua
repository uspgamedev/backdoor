
--- Get actor's card from hand

local OP = {}

OP.schema = {
  { id = 'output', name = "Label", type = 'output' },
  { id = 'actor', name = "Actor", type = "value", match = 'actor' },
  { id = 'card-index', name = "Position in Hand", type = "value",
    match = 'integer', range = {1} }
}

OP.type = 'card'

function OP.process(actor, sector, params)
  local self = params['actor']
  local index = params['card-index']
  return self:getHandCard(index)
end

return OP

