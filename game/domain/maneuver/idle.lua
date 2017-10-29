
local ACTIONDEFS = require 'domain.definitions.action'
local IDLE = {}

IDLE.param_specs = {}

function IDLE.activatedAbility(actor, sector, params)
  return nil
end

function IDLE.validate(actor, sector, params)
  return true
end

function IDLE.perform(actor, sector, params)
  actor:spendTime(ACTIONDEFS.IDLE_TIME)
end

return IDLE

