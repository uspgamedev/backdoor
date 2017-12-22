
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
  coroutine.yield('report', {
    type = 'body_acted',
    body = actor:getBody(),
  })
  actor:exhaust(signature.cost)
  actor:getBody():triggerWidgets(DEFS.TRIGGERS.ON_ACT)
  ABILITY.execute(signature.ability, actor, params)
end

return SIGNATURE

