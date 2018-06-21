
local ABILITY     = require 'domain.ability'
local ACTIONSDEFS = require 'domain.definitions.action'
local GameElement = require 'domain.gameelement'

local Card = Class{
  __includes = { GameElement }
}

function Card:init(specname)

  GameElement.init(self, 'card', specname)
  self.usages = 0
  self.owner_id = nil
  self.ticks = 0

end

function Card:loadState(state)
  self:setId(state.id or self.id)
  self:setSubtype(self.spectype)
  self.specname = state.specname or self.specname
  self.usages = state.usages or self.usages
  self.owner_id = state.owner_id or self.owner_id
  self.ticks = state.ticks or self.ticks
end

function Card:saveState()
  local state = {}
  state.id = self:getId()
  state.specname = self.specname
  state.usages = self.usages
  state.owner_id = self.owner_id
  state.ticks = self.ticks
  return state
end

function Card:getName()
  return self:getSpec('name')
end

function Card:getDescription()
  return self:getSpec('desc')
end

function Card:getIconTexture()
  return self:getSpec('icon')
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

function Card:getType()
  if self:isArt() then return 'art'
  elseif self:isUpgrade() then return 'upgrade'
  elseif self:isWidget() then return 'widget'
  end
end

function Card:getArtAbility()
  return self:getSpec('art').art_ability
end

function Card:getArtCost()
  return self:getSpec('art').cost
end

function Card:getUpgradesList()
  return self:getSpec('upgrade').attr_list
end

function Card:getUpgradeCost()
  return self:getSpec('upgrade').cost
end

function Card:getWidgetTrigger()
  return self:getSpec('widget')['trigger']
end

function Card:getWidgetTriggerCondition()
  return self:getSpec('widget')['trigger-condition']
end

function Card:getStaticOperators()
  return ipairs(self:getSpec('widget')['operators'] or {})
end

function Card:hasStatusTag(tag)
  local status_list = self:getSpec('widget')['status-tags'] or {}
  for _,status in ipairs(status_list) do
    if status['tag'] == tag then
      return true
    end
  end
  return false
end

function Card:getWidgetActivation()
  return self:getSpec('widget')['activation']
end

function Card:getWidgetTriggeredAbility()
  return self:getSpec('widget')['auto_activation']
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

function Card:isWidgetPermanent()
  return self:getWidgetCharges() == 0
end

function Card:resetUsages()
  self.usages = 0
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

function Card:resetTicks()
  self.ticks = 0
end

function Card:tick()
  self.ticks = self.ticks + 1
  if self.ticks >= ACTIONSDEFS.CYCLE_UNIT then
    self.ticks = 0
    return true
  end
  return false
end

function Card:getEffect()
  local effect
  local inputs = { self = self:getOwner() }
  if self:isArt() then
    effect = ("Art [%d exhaustion]\n\n"):format(self:getArtCost())
          .. ABILITY.preview(self:getArtAbility(), self:getOwner(), inputs)
  elseif self:isUpgrade() then
    local ups,n = {}, 0
    for _,up in ipairs(self:getUpgradesList()) do
      n = n + 1
      ups[n] = "+" .. up.val .. " " .. up.attr
    end
    effect = ("Upgrade [%s]"):format(table.concat(ups, ', '))
  elseif self:isWidget() then
    effect = "Widget"
    local place = self:getWidgetPlacement() if place then
      effect = effect .. " [" .. place .. "]"
    end
    local charges = self:getWidgetCharges() if charges > 0 then
      local trigger = self:getWidgetTrigger()
      effect = effect .. (" [%d/%s charges]"):format(charges, trigger)
    end
    local activation = self:getWidgetActivation() if activation then
      local ability, cost = activation.ability, activation.cost
      effect = effect .. ("\n\nActivate [%d exhaustion]: "):format(cost)
                      .. ABILITY.preview(ability, self:getOwner(), inputs)
    end
    local auto = self:getWidgetTriggeredAbility() if auto then
      local ability, trigger = auto.ability, auto.trigger
      effect = effect .. ("\n\nTrigger [%s]: "):format(trigger)
                      .. ABILITY.preview(ability, self:getOwner(), inputs)
    end
    local ops, n = {}, 0
    for _,op in self:getStaticOperators() do
      n = n + 1
      ops[n] = ("%s%d %s"):format(op.op, op.val, op.attr)
    end
    if n > 0 then
      effect = effect .. "\n\n" .. table.concat(ops, ", ") .. "."
    end
  end
  return effect
end

return Card

