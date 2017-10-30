
local DEFS = require 'domain.definitions'

local DRAWHAND = {}

DRAWHAND.param_specs = {}

function DRAWHAND.activatedAbility(actor, sector, params)
  return nil
end

function DRAWHAND.validate(actor, sector, params)
  return actor:isHandEmpty() and actor:getPP() >= DEFS.ACTION.NEW_HAND_COST
end

function DRAWHAND.perform(actor, sector, params)
  actor:spendPP(DEFS.ACTION.NEW_HAND_COST)
  for i = 1, DEFS.HAND_LIMIT do
    actor:drawCard()
  end
end

return DRAWHAND

