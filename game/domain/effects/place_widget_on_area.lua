
local RANDOM = require 'common.random'
local Card = require 'domain.card'
local FX = {}

FX.schema = {
  { id = 'center', name = "Target position", type = 'value', match = 'pos' },
  { id = 'ignore_owner', name = "Ignore Owner", type = 'boolean'},
  { id = 'size', name = "Area Size", type = 'value', match = 'integer',
    range = {1} },
  { id = 'card', name = "Card Specname", type = 'enum',
    options = "domains.card" },
}

function FX.process (actor, params)
  local sector        = actor:getBody():getSector()
  local ci, cj        = unpack(params['center'])
  local size          = params['size']
  local cardspec      = params['card']
  local ignore_owner  = params['ignore_owner']
  for i=ci-size+1,ci+size-1 do
    for j=cj-size+1,cj+size-1 do
      local body = sector:getBodyAt(i, j) if body then
        if not ignore_owner or body ~= actor:getBody() then
          local card = Card(cardspec)
          card:setOwner(actor)
          body:placeWidget(card)
        end
      end
    end
  end
end

return FX
