
local DB = require 'database'
local Card = require 'domain.card'
local FX = {}

FX.schema = {
  { id = 'center', name = "Target position", type = 'value', match = 'pos' },
  { id = 'ignore_owner', name = "Ignore Owner", type = 'boolean'},
  { id = 'size', name = "Area Size", type = 'value', match = 'integer',
    range = {1} },
  { id = 'cardspec', name = "Card Specname", type = 'enum',
    options = "domains.card" },
}

function FX.preview(_, fieldvalues)
  local name = DB.loadSpec('card', fieldvalues['cardspec'])['name']
  local size = fieldvalues['size'] - 1
  local center = fieldvalues['center']
  return ("cause %s on %s-radius area around %s"):format(name, size, center)
end

function FX.process (actor, fieldvalues)
  local sector        = actor:getBody():getSector()
  local ci, cj        = unpack(fieldvalues['center'])
  local size          = fieldvalues['size']
  local cardspec      = fieldvalues['cardspec']
  local ignore_owner  = fieldvalues['ignore_owner']
  for i=ci-size+1,ci+size-1 do
    for j=cj-size+1,cj+size-1 do
      local body = sector:getBodyAt(i, j) if body then
        if not ignore_owner or body ~= actor:getBody() then
          local card = Card(cardspec)
          card:setOwner(actor)
          body:placeWidget(card)
          coroutine.yield('report', {
            type = 'place_widget_card',
            body = body,
            card = card,
            sfx = fieldvalues.sfx,
          })
        end
      end
    end
  end
end

return FX
