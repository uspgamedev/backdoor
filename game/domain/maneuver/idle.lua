
local ACTIONDEFS = require 'domain.definitions.action'
local IDLE = {}

IDLE.input_specs = {}

function IDLE.card(actor, inputvalues)
  return nil
end

function IDLE.activatedAbility(actor, inputvalues)
  return nil
end

function IDLE.exhaustionCost(actor, inputvalues)
  return ACTIONDEFS.IDLE_COST
end

function IDLE.validate(actor, inputvalues)
  return true
end

function IDLE.perform(actor, inputvalues)
  actor:exhaust(ACTIONDEFS.IDLE_COST)
end

return IDLE

