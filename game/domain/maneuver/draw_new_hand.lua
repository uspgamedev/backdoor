
local DEFS = require 'domain.definitions'

local DRAWHAND = {}

DRAWHAND.input_specs = {}

function DRAWHAND.card(actor, inputvalues) -- luacheck: no unused
  return nil
end

function DRAWHAND.activatedAbility(actor, inputvalues) -- luacheck: no unused
  return nil
end

function DRAWHAND.exhaustionCost(actor, inputvalues) -- luacheck: no unused
  return 0
end

function DRAWHAND.validate(actor, inputvalues) -- luacheck: no unused
  return not actor:isBufferEmpty()
         and actor:getPP() >= actor:getBody():getConsumption()
end

function DRAWHAND.perform(actor, inputvalues) -- luacheck: no unused
  actor:spendPP(actor:getBody():getConsumption())
  actor:discardHand()
  actor:resetFocus()
  for _ = 1, DEFS.HAND_LIMIT do
    actor:drawCard()
  end
end

return DRAWHAND

