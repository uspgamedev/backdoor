
local ACTIONDEFS  = require 'domain.definitions.action'
local ABILITY     = require 'domain.ability'
local ACTIVATE   = {}

ACTIVATE.param_specs = {
  { output = 'widget_slot', typename = 'choose_widget_slot' }
}

function ACTIVATE.activatedAbility(actor, sector, params)
  return actor:getWidget(params.widget_slot):getWidgetAbility()
end

function ACTIVATE.validate(actor, sector, params)
  if not params.widget_slot then return false end
  local widget = actor:getWidget(params.widget_slot)
  if not widget then return false end
  local ability = widget:getWidgetAbility()
  return ability and ABILITY.checkParams(ability, actor, sector, params)
end

function ACTIVATE.perform(actor, sector, params)
  local widget = actor:getWidget(params.widget_slot)
  local ability = widget:getWidgetAbility()
  actor:spendWidget(params.widget_slot)
  actor:spendTime(widget:getWidgetActivationCost())
  actor:rewardPP(widget:getPPReward())
  ABILITY.execute(ability, actor, sector, params)
end

return ACTIVATE

