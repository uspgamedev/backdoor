
local DEFS = require 'domain.definitions'

local DRAWHAND = {}

DRAWHAND.param_specs = {}

function DRAWHAND.activatedAbility(actor, sector, params)
  return nil
end

function DRAWHAND.validate(actor, sector, params)
  return actor:isHandEmpty() and actor:getPP() >= DEFS.NEW_HAND_COST
end

function DRAWHAND.perform(actor, sector, params)
  for i = 1, DEFS.HAND_LIMIT do
    actor:drawCard()
  end
end

return DRAWHAND

