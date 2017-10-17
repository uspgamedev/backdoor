
local GameElement = require 'domain.gameelement'

local Card = Class{
  __includes = { GameElement }
}

function Card:init(specname)

  GameElement.init(self, 'card', specname)
  self.usages = 0

end

function Card:loadState(state)
  self.specname = state.specname
  self.usages = state.usages
end

function Card:saveState()
  local state = {}
  state.specname = self.specname
  state.usages = self.usages
  return state
end

function Card:getName()
  return self:getSpec('name')
end

function Card:getRelatedAttr()
  return self:getSpec('attr')
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

function Card:getArtAction()
  return self:getSpec('art').art_action
end

function Card:getUpgradesList()
  return self:getSpec('upgrade').list
end

function Card:getUpgradeCost()
  return self:getSpec('upgrade').cost
end

function Card:getWidgetAction()
  return self:getSpec('widget').widget_action
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

