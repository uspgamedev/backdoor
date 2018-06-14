
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
  { id = 'ignore_owner', name = "Ignore Owner", type = 'boolean'},
  { id = 'size', name = "Area Size", type = 'value', match = 'integer',
    range = {1} },
}

function FX.process (actor, fieldvalues)
  local sector  = actor:getBody():getSector()
  local ci, cj  = unpack(fieldvalues['center'])
  local size    = fieldvalues['size']
  local attr    = fieldvalues['attr']
  local base    = fieldvalues['base']
  local ignore_owner = fieldvalues['ignore_owner']
  local amount = RANDOM.rollDice(base, attr)
  for i=ci-size+1,ci+size-1 do
    for j=cj-size+1,cj+size-1 do
      local body = sector:getBodyAt(i, j) if body then
        if not ignore_owner or body ~= actor:getBody() then
          local dmg = body:takeDamageFrom(amount, actor)
          coroutine.yield('report', {
            type = 'text_rise',
            text_type = 'damage',
            body = body,
            amount = dmg,
          })
        end
      end
    end
  end
end

return FX
