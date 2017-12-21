
local DEFS        = require 'domain.definitions'
local ACTIONDEFS  = require 'domain.definitions.action'
local ABILITY     = require 'domain.ability'
local SIGNATURE   = {}

SIGNATURE.param_specs = {}

function SIGNATURE.activatedAbility(actor, params)
  return actor:getSignature().ability
end

function SIGNATURE.validate(actor, params)
  return ABILITY.checkParams(actor:getSignature().ability, actor, params)
end

function SIGNATURE.perform(actor, params)
  local signature = actor:getSignature()
  actor:exhaust(signature.cost)
  --actor:rewardPP(signature.playpoints or 0)
  actor:getBody():triggerWidgets(DEFS.TRIGGERS.ON_ACT)
  ABILITY.execute(signature.ability, actor, params)
end

return SIGNATURE

