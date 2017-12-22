
local ACTIONDEFS  = require 'domain.definitions.action'
local ABILITY     = require 'domain.ability'
local DEFS        = require 'domain.definitions'
local ACTIVATE   = {}

ACTIVATE.param_specs = {
  { output = 'widget_slot', typename = 'choose_widget_slot' }
}

function ACTIVATE.activatedAbility(actor, params)
  return actor:getBody():getWidget(params.widget_slot):getWidgetAbility()
end

function ACTIVATE.validate(actor, params)
  if not params.widget_slot then return false end
  local widget = actor:getBody():getWidget(params.widget_slot)
  if not widget then return false end
  local ability = widget:getWidgetAbility()
  return ability and ABILITY.checkParams(ability, actor, params)
end

function ACTIVATE.perform(actor, params)
  local body = actor:getBody()
  local widget = body:getWidget(params.widget_slot)
  local ability = widget:getWidgetAbility()
  coroutine.yield('report', {
    type = 'body_acted',
    body = body,
  })
  actor:exhaust(widget:getWidgetActivationCost())
  ABILITY.execute(ability, actor, params)
  body:triggerWidgets(DEFS.TRIGGERS.ON_ANY_USE, { activated_widget = widget })
  body:triggerWidgets(DEFS.TRIGGERS.ON_ACT)
  body:triggerOneWidget(params.widget_slot, DEFS.TRIGGERS.ON_USE)
end

return ACTIVATE

