
local ACTIONDEFS = require 'domain.definitions.action'
local IDLE = {}

IDLE.param_specs = {}

function IDLE.activatedAbility(actor, params)
  return nil
end

function IDLE.validate(actor, params)
  return true
end

function IDLE.perform(actor, params)
  actor:spendTime(ACTIONDEFS.IDLE_TIME)
end

return IDLE

