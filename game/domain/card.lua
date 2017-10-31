
local ABILITY     = require 'domain.ability'
local GameElement = require 'domain.gameelement'

local Card = Class{
  __includes = { GameElement }
}

function Card:init(specname)

  GameElement.init(self, 'card', specname)
  self.usages = 0
  self.owner_id = nil

end

function Card:loadState(state)
  self.specname = state.specname
  self.usages = state.usages
  self.owner_id = state.owner_id
end

function Card:saveState()
  local state = {}
  state.specname = self.specname
  state.usages = self.usages
  state.owner_id = self.owner_id
  return state
end

function Card:getName()
  return self:getSpec('name')
end

function Card:getDescription()
  return self:getSpec('desc')
end

function Card:getPPReward()
  return self:getSpec('pp') or 0
end

function Card:getRelatedAttr()
  return self:getSpec('attr')
end

function Card:getOwner()
  return Util.findId(self.owner_id)
end

function Card:setOwner(owner)
  self.owner_id = owner.id
end

function Card:isOneTimeOnly()
  return self:isUpgrade() or self:getSpec('one_time')
end

function Card:isArt()
  return not not self:getSpec('art')
end

function Card:isUpgrade()
  return not not self:getSpec('upgrade')
end

function Card:isWidget()
  return not not self:getSpec('widget')
end

function Card:getArtAbility()
  return self:getSpec('art').art_ability
end

function Card:getArtCost()
  return self:getSpec('art').cost
end

function Card:getUpgradesList()
  return {
    actor = self:getSpec('upgrade').actor_list,
    body = self:getSpec('upgrade').body_list,
  }
end

function Card:getUpgradeCost()
  return self:getSpec('upgrade').cost
end

function Card:getStaticOperators()
  return ipairs(self:getSpec('widget')['operators'] or {})
end

function Card:getWidgetActivation()
  return self:getSpec('widget')['activation']
end

function Card:getWidgetAbility()
  local activation = self:getWidgetActivation()
  return activation and activation.ability
end

function Card:getWidgetActivationCost()
  local activation = self:getWidgetActivation()
  return activation and activation.cost
end

function Card:getWidgetPlacement()
  return self:getSpec('widget').placement
end

function Card:getWidgetCharges()
  return self:getSpec('widget').charges
end

function Card:addUsages(n)
  self.usages = self.usages + (n or 1)
end

function Card:getUsages()
  return self.usages
end

function Card:isSpent()
  local max = self:getWidgetCharges()
  return max > 0 and self:getUsages() >= max
end

return Card

