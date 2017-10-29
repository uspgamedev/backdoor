
local ACTIONDEFS  = require 'domain.definitions.action'
local ABILITY     = require 'domain.ability'
local SIGNATURE   = {}

SIGNATURE.param_specs = {}

function SIGNATURE.activatedAbility(actor, sector, params)
  return actor:getSignature().ability
end

function SIGNATURE.validate(actor, sector, params)
  return ABILITY.checkParams(actor:getSignature().ability, actor, sector,
                             params)
end

function SIGNATURE.perform(actor, sector, params)
  local signature = actor:getSignature()
  actor:spendTime(signature.cost)
  actor:rewardPP(signature.playpoints or 0)
  ABILITY.execute(signature.ability, actor, sector, params)
end

return SIGNATURE

