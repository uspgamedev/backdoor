
local DEFS = require 'domain.definitions'

local DRAWHAND = {}

DRAWHAND.param_specs = {}

function DRAWHAND.activatedAbility(actor, params)
  return nil
end

function DRAWHAND.validate(actor, params)
  return not actor:isBufferEmpty()
         and actor:isHandEmpty()
         and actor:getPP() >= DEFS.ACTION.NEW_HAND_COST
end

function DRAWHAND.perform(actor, params)
  actor:spendPP(DEFS.ACTION.NEW_HAND_COST)
  for i = 1, DEFS.HAND_LIMIT do
    actor:drawCard()
  end
end

return DRAWHAND

