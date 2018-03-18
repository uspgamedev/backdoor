
local Card = require 'domain.card'

local FX = {}

FX.schema = {
  { id = 'body', name = "Target Body", type = 'value', match = "body" },
  { id = 'card', name = "Card Specname", type = 'enum',
    options = "domains.card" },
}

function FX.process(actor, fieldvalues)
  local card = Card(fieldvalues['card'])
  card:setOwner(actor)
  fieldvalues['body']:placeWidget(card)
end

return FX
