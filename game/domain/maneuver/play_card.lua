
local ACTIONDEFS  = require 'domain.definitions.action'
local TRIGGERS    = require 'domain.definitions.triggers'
local ABILITY     = require 'domain.ability'

local PLAYCARD = {}

PLAYCARD.param_specs = {
  { output = 'card_index', typename = 'card_index' }
}

local function _card(actor, params)
  return actor:getHandCard(params.card_index)
end

function PLAYCARD.activatedAbility(actor, params)
  local card = _card(actor, params)
  return card:isArt() and card:getArtAbility()
end

function PLAYCARD.validate(actor, params)
  local card = _card(actor, params)
  local valid = false
  if card:isArt() then
    valid = ABILITY.checkParams(card:getArtAbility(), actor, params)
  elseif card:isWidget() then
    valid = true
  elseif card:isUpgrade() then
    valid = actor:getExp() >= card:getUpgradeCost()
  end
  return valid
end

function PLAYCARD.perform(actor, params)
  local card = _card(actor, params)
  local body = actor:getBody()
  actor:playCard(params.card_index)

  if card:isArt() then
    coroutine.yield('report', {
      type = 'body_acted',
      body = body,
    })
    actor:exhaust(card:getArtCost())
    ABILITY.execute(card:getArtAbility(), actor, params)
    body:triggerWidgets(TRIGGERS.ON_ACT)
  elseif card:isWidget() then
    actor:exhaust(ACTIONDEFS.PLAY_WIDGET_COST)
    body:placeWidget(card)
  elseif card:isUpgrade() then
    actor:exhaust(ACTIONDEFS.PLAY_UPGRADE_COST)
    actor:modifyExpBy(-card:getUpgradeCost())
    local upgrades = card:getUpgradesList()
    for _,upgrade in ipairs(upgrades.actor) do
      local attr = upgrade.attr
      local val = upgrade.val
      actor["upgrade"..attr](actor, val)
    end
    local body = actor:getBody() if body then
      for _,upgrade in ipairs(upgrades.body) do
        local attr = upgrade.attr
        local val = upgrade.val
        body["upgrade"..attr](body, val)
      end
    end
  end

  body:triggerWidgets(TRIGGERS.ON_PLAY, { card = card })
end

return PLAYCARD

