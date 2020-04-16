
local ACTIONDEFS  = require 'domain.definitions.action'

local DISCARD_CARD = {}

DISCARD_CARD.input_specs = {
  { output = 'card_index', name = 'card_index' }
}

function DISCARD_CARD.card(_, _)
  return nil
end

function DISCARD_CARD.activatedAbility(_, _)
  return nil
end

function DISCARD_CARD.exhaustionCost(_, _)
  return ACTIONDEFS.DISCARD_COST
end

function DISCARD_CARD.validate(actor, inputvalues)
  return inputvalues.card_index <= actor:getHandSize()
end

function DISCARD_CARD.perform(actor, inputvalues)
  local index = inputvalues.card_index
  actor:exhaust(ACTIONDEFS.DISCARD_COST)
  actor:discardCard(index)
end

return DISCARD_CARD
