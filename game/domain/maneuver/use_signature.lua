
local DEFS        = require 'domain.definitions'
local ACTIONDEFS  = require 'domain.definitions.action'
local ABILITY     = require 'domain.ability'
local SIGNATURE   = {}

SIGNATURE.input_specs = {}

function SIGNATURE.card(actor, inputvalues)
  return nil
end

function SIGNATURE.activatedAbility(actor, inputvalues)
  return actor:getSignature().ability
end

function SIGNATURE.exhaustionCost(actor, inputvalues)
  return actor:getSignature().cost
end

function SIGNATURE.validate(actor, inputvalues)
  return ABILITY.checkInputs(actor:getSignature().ability, actor, inputvalues)
end

function SIGNATURE.perform(actor, inputvalues)
  local signature = actor:getSignature()
  coroutine.yield('report', {
    type = 'body_acted',
    body = actor:getBody(),
  })
  actor:exhaust(signature.cost)
  actor:getBody():triggerWidgets(DEFS.TRIGGERS.ON_ACT)
  ABILITY.execute(signature.ability, actor, inputvalues)
end

return SIGNATURE

