
local MANEUVERS = require 'lux.pack' 'domain.maneuver'
local ABILITY = require 'domain.ability'
local DB      = require 'database'

local ACTION = {}

function ACTION.paramsOf(action_name)
  return ABILITY.paramsOf(ACTION.ability(action_name))
end

function ACTION.ability(action_name)
  return (DB.loadSpec('action', action_name) or {}).ability
end

--------------------------------------------------------------------------------

function ACTION.castArt(art_card_index, actor, sector, params)
  local art_card = actor:getCard(art_card_index)
  local art_ability = art_card:getArtAbility()
  if not ABILITY.checkParams(art_ability, actor, sector, params) then
    return false
  end
  actor:playCard(art_card_index)
  actor:spendTime(art_card:getArtCost())
  actor:rewardPP(art_card:getPPReward())
  ABILITY.execute(art_ability, actor, sector, params)
  return true
end

function ACTION.activateWidget(widget_card_slot, actor, sector, params)
  local widget_card = actor:getWidget(widget_card_slot)
  local widget_ability = widget_card:getWidgetAbility()
  if not ABILITY.checkParams(widget_ability, actor, sector, params) then
    return false
  end
  actor:spendWidget(action_slot)
  actor:spendTime(widget_card:getWidgetActivationCost())
  actor:rewardPP(widget_card:getPPReward())
  ABILITY.execute(widget_ability, actor, sector, params)
  return true
end

function ACTION.useSignature(actor, sector, params)
  return ACTION.useBasicAblity('PRIMARY', actor, sector, params)
end

function ACTION.useBasicAblity(action_slot, actor, sector, params)
  local action_name = actor:getAction(action_slot)
  local spec = DB.loadSpec("action", action_name)
  if not ABILITY.checkParams(spec.ability, actor, sector, params) then
    return false
  end
  if actor:isCard(action_slot) then
    actor:playCard(action_slot)
  end
  actor:spendTime(spec.cost)
  actor:rewardPP(spec.playpoints or 0)
  ABILITY.execute(spec.ability, actor, sector, params)
  return true
end

function ACTION.makeManeuver(action_slot, actor, sector, params)
  local action_name = actor:getAction(action_slot)
  local maneuver = MANEUVERS[action_name:lower()]

  if not maneuver or not maneuver.validate(actor, sector, params) then
    return false
  end
  maneuver.perform(actor, sector, params)

  return true
end

return ACTION

