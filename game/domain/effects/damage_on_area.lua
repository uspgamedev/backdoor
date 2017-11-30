
local RANDOM = require 'common.random'
local FX = {}

FX.schema = {
  {
    id = 'attr', name = "Attribute", type = 'value',
    match = 'integer', range = {1}
  },
  { id = 'base', name = "Base Power", type = 'value',
    match = 'integer', range = {1} },
  { id = 'center', name = "Target position", type = 'value', match = 'pos' },
  { id = 'size', name = "Area Size", type = 'value', match = 'integer',
    range = {1} },
}

function FX.process (actor, params)
  local sector  = actor:getBody():getSector()
  local ci, cj  = unpack(params['center'])
  local size    = params['size']
  local attr    = params['attr']
  local base    = params['base']
  local amount = RANDOM.rollDice(base, attr)
  for i=ci-size+1,ci+size-1 do
    for j=cj-size+1,cj+size-1 do
      local body = sector:getBodyAt(i, j) if body then
        body:takeDamageFrom(amount, actor)
      end
    end
  end
end

return FX
