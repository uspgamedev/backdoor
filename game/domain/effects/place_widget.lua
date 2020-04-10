
local Card = require 'domain.card'
local DB = require 'database'

local FX = {}

FX.schema = {
  { id = 'body', name = "Target Body", type = 'value', match = "body" },
  { id = 'card', name = "Card Specname", type = 'enum',
    options = "domains.card" },
}

function FX.preview(_, fieldvalues)
  local name = DB.loadSpec('card', fieldvalues['card'])['name']
  return ("Cause %s to %s"):format(name, fieldvalues['body'])
end

function FX.process(actor, fieldvalues)
  local card = Card(fieldvalues['card'])
  local body = fieldvalues['body']
  card:setOwner(actor)
  body:placeWidget(card)
  coroutine.yield('report', {
    type = 'text_rise',
    text_type = 'status',
    body = body,
    string = card:getName(),
    sfx = fieldvalues.sfx,
  })
end

return FX
