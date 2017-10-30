
local ACTIONDEFS  = require 'domain.definitions.action'
local ABILITY     = require 'domain.ability'
local PLAYCARD   = {}

PLAYCARD.param_specs = {
  { output = 'card_index', typename = 'card_index' }
}

local function _card(actor, params)
  return actor:getCard(params.card_index)
end

function PLAYCARD.activatedAbility(actor, sector, params)
  local card = _card(actor, params)
  return card:isArt() and card:getArtAbility()
end

function PLAYCARD.validate(actor, sector, params)
  local card = _card(actor, params)
  local valid = false
  if card:isArt() then
    valid = ABILITY.checkParams(card:getArtAbility(), actor, sector, params)
  elseif card:isWidget() then
    valid = true
  elseif card:isUpgrade() then
    valid = actor:getExp() >= card:getUpgradeCost()
  end
  return valid
end

function PLAYCARD.perform(actor, sector, params)
  local card = _card(actor, params)
  actor:playCard(params.card_index)
  if card:isArt() then
    actor:spendTime(card:getArtCost())
    actor:rewardPP(card:getPPReward())
    ABILITY.execute(card:getArtAbility(), actor, sector, params)
  elseif card:isWidget() then
    actor:getBody():placeWidget(card)
  elseif card:isUpgrade() then
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
end

return PLAYCARD

