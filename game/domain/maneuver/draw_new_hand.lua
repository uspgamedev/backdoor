
local DEFS = require 'domain.definitions'

local DRAWHAND = {}

DRAWHAND.input_specs = {}

function DRAWHAND.activatedAbility(actor, inputvalues)
  return nil
end

function DRAWHAND.validate(actor, inputvalues)
  return not actor:isBufferEmpty()
         and actor:getPP() >= DEFS.ACTION.NEW_HAND_COST
end

function DRAWHAND.perform(actor, inputvalues)
  actor:spendPP(DEFS.ACTION.NEW_HAND_COST)
  while not actor:isHandEmpty() do
    local card = actor:removeHandCard(1)
    actor:addCardToBackbuffer(card)
  end
  for i = 1, DEFS.HAND_LIMIT do
    actor:drawCard()
  end
end

return DRAWHAND

