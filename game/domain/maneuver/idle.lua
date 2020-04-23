
local ACTIONDEFS = require 'domain.definitions.action'
local IDLE = {}

IDLE.input_specs = {}

function IDLE.card(_, _)
  return nil
end

function IDLE.activatedAbility(_, _)
  return nil
end

function IDLE.exhaustionCost(_, _)
  return ACTIONDEFS.HALF_EXHAUSTION
end

function IDLE.validate(_, _)
  return true
end

function IDLE.perform(actor, _)
  actor:exhaust(ACTIONDEFS.HALF_EXHAUSTION)
end

return IDLE

