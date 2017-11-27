
local RANDOM = require 'common.random'
local FX = {}

FX.schema = {
  {
    id = 'attr', name = "Attribute", type = 'value',
    match = 'integer', range = {1}
  },
  { id = 'base', name = "Base Power", type = 'value',
    match = 'integer', range = {1} },
  { id = 'target', name = "Target", type = 'value', match = 'body' },
}

function FX.process (actor, params)
  local amount = RANDOM.rollDice(params.base, params.attr)
  params.target:takeDamageFrom(amount, actor)
end

return FX

