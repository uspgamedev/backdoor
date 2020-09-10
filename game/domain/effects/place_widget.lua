
local DB = require 'database'

local FX = {}

FX.schema = {
  { id = 'body', name = "Target Body", type = 'value', match = "body" },
  { id = 'cardspec', name = "Card Specname", type = 'enum',
    options = "domains.card" },
}

function FX.preview(_, fieldvalues)
  local name = DB.loadSpec('card', fieldvalues['cardspec'])['name']
  return ("cause %s to %s"):format(name, fieldvalues['body'])
end

function FX.process(actor, fieldvalues)
  local route = actor:getSector():getRoute()
  local card = route.makeCard(fieldvalues['cardspec'], actor:getId())
  local body = fieldvalues['body']
  body:placeWidget(card)
  coroutine.yield('report', {
    type = 'place_widget_card',
    body = body,
    card = card,
    sfx = fieldvalues.sfx,
  })
end

return FX
