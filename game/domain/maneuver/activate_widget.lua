
local ACTIONDEFS  = require 'domain.definitions.action'
local ABILITY     = require 'domain.ability'
local DEFS        = require 'domain.definitions'
local ACTIVATE   = {}

ACTIVATE.input_specs = {
  { output = 'widget_slot', name = 'choose_widget_slot' }
}

function ACTIVATE.card(actor, inputvalues)
  return actor:getBody():getWidget(inputvalues.widget_slot)
end

function ACTIVATE.activatedAbility(actor, inputvalues)
  return actor:getBody():getWidget(inputvalues.widget_slot):getWidgetAbility()
end

function ACTIVATE.exhaustionCost(actor, inputvalues)
  local widget = actor:getBody():getWidget(inputvalues.widget_slot)
  return widget and widget:getWidgetActivationCost() or 0
end

function ACTIVATE.validate(actor, inputvalues)
  if not inputvalues.widget_slot then return false end
  local widget = actor:getBody():getWidget(inputvalues.widget_slot)
  if not widget then return false end
  local ability = widget:getWidgetAbility()
  return ability and ABILITY.checkInputs(ability, actor, inputvalues)
end

function ACTIVATE.perform(actor, inputvalues)
  local body = actor:getBody()
  local widget = body:getWidget(inputvalues.widget_slot)
  local ability = widget:getWidgetAbility()
  coroutine.yield('report', {
    type = 'body_acted',
    body = body,
  })
  actor:exhaust(widget:getWidgetActivationCost())
  ABILITY.execute(ability, actor, inputvalues)
  body:triggerWidgets(DEFS.TRIGGERS.ON_ANY_USE, { activated_widget = widget })
  body:triggerWidgets(DEFS.TRIGGERS.ON_ACT)
  body:triggerOneWidget(inputvalues.widget_slot, DEFS.TRIGGERS.ON_USE)
end

return ACTIVATE

