
local Card = require 'domain.card'

local FX = {}

FX.schema = {
  { id = 'body', name = "Target Body", type = 'value', match = "body" },
  { id = 'card', name = "Card Specname", type = 'enum',
    options = "domains.card" },
}

function FX.process(actor, params)
  local card = Card(params['card'])
  card:setOwner(actor)
  params['body']:placeWidget(card)
end

return FX
