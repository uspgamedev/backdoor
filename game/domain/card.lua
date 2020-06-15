
local ABILITY     = require 'domain.ability'
local TRIGGERS    = require 'domain.definitions.triggers'
local ACTIONSDEFS = require 'domain.definitions.action'
local DB          = require 'database'
local GameElement = require 'domain.gameelement'
local Util        = require "steaming.util"
local Class       = require "steaming.extra_libs.hump.class"

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

function Card:getRelatedAttr()
  return self:getSpec('attr')
end

function Card:getLevel()
  return self:getSpec('level')
end

function Card:getOwner()
  return Util.findId(self.owner_id)
end

function Card:setOwner(owner)
  self.owner_id = owner.id
end

function Card:isOneTimeOnly()
  return self:getSpec('one_time')
end

function Card:isTemporary()
  return self:getSpec('temporary')
end

function Card:getCost()
  return self:getSpec('cost')
end

function Card:isHalfExhaustion()
  return self:getSpec('half-exhaustion')
end

function Card:getExhaustion()
  if self:getSpec('half-exhaustion') then
    return ACTIONSDEFS.HALF_EXHAUSTION
  else
    return ACTIONSDEFS.FULL_EXHAUSTION
  end
end

function Card:isArt()
  return not not self:getSpec('art')
end

function Card:isWidget()
  return not not self:getSpec('widget')
end

function Card:getType()
  if self:isArt() then return 'art'
  elseif self:isWidget() then return 'widget'
  end
end

--[[ Art methods ]]--

function Card:getArtAbility()
  return self:getSpec('art').art_ability
end

--[[ Widget methods ]]--

function Card:getWidgetTrigger()
  return self:getSpec('widget')['trigger']
end

function Card:getWidgetTriggerCondition()
  return self:getSpec('widget')['trigger-condition']
end

function Card:getStaticAbilities()
  return ipairs(self:getSpec('widget')['static'] or {})
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

function Card:getWidgetTriggeredAbility()
  return self:getSpec('widget')['auto_activation']
end

function Card:getWidgetPlacement()
  local equipspec = self:getSpec('widget').equipment
  return equipspec
     and ((equipspec.active and 'wieldable')
       or (equipspec.defensive and 'wearable'))
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

function Card:getCurrentWidgetCharges()
  return self:getWidgetCharges() - self:getUsages()
end

function Card:isSpent()
  local max = self:getWidgetCharges()
  return max > 0 and self:getUsages() >= max
end

function Card:isEquipment()
  return self:getSpec('widget').equipment
end

function Card:getActiveEquipmentCardCount()
  return #self:getSpec('widget').equipment.active.cards
end

function Card:eachActiveEquipmentCards()
  return ipairs(self:getSpec('widget').equipment.active.cards)
end

function Card:getEquipmentDefense()
  return self:getSpec('widget').equipment.defensive.defense
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

local _EPQ_TYPENAMES = {
  wieldable = "Weapon",
  wearable = "Armor",
}

function Card:getEffect()
  local effect = ""
  local inputs = { self = self:getOwner() }
  if self:isTemporary() then
    effect = effect .. "Temporary "
  elseif self:isOneTimeOnly() then
    effect = effect .. "Single-Use "
  end
  if self:isArt() then
    effect = effect .. "Art\n\n"
    effect = effect .. ABILITY.preview(self:getArtAbility(), self:getOwner(),
                                       inputs, true)
  elseif self:isWidget() then
    local place = self:getWidgetPlacement() if place then
      effect = effect .. _EPQ_TYPENAMES[place]
    else
      effect = effect .. "Condition"
    end
    local charges = self:getWidgetCharges() if charges > 0 then
      local trigger = self:getWidgetTrigger()
      effect = effect .. (" (%d charges%s)"):format(
        charges,
        trigger and "/" .. trigger or ""
      )
    end
    do -- static abilities
      local abs, n = {}, 0
      for _,ab in self:getStaticAbilities() do
        n = n + 1
        abs[n] = ab.descr ~= "" and ab.descr
                                 or "Missing static ability description."
      end
      if n > 0 then
        effect = effect .. "\n\n" .. table.concat(abs, "\n\n")
      end
    end
    do -- static operators
      local ops, n = {}, 0
      for _,op in self:getStaticOperators() do
        n = n + 1
        ops[n] = ("You get %s %s%d"):format(op.attr, op.op, op.val)
      end
      if n > 0 then
        effect = effect .. "\n\n" .. table.concat(ops, ", ") .. "."
      end
    end
    local auto = self:getWidgetTriggeredAbility() if auto then
      local ability, trigger = auto.ability, TRIGGERS.WORDING[auto.trigger]
      effect = effect .. ("\n\n%s, "):format(trigger)
                      .. ABILITY.preview(ability, self:getOwner(), inputs)
    end
    -- TODO: describe created cards
    local equip = self:getSpec('widget').equipment
    if equip and equip.active then
      effect = effect .. "\n"
      local count = {}
      for _, action in ipairs(equip.active.cards) do
        local spec = DB.loadSpec('card', action.card)
        count[spec] = (count[spec] or 0) + 1
      end
      for spec, k in pairs(count) do
        effect = effect .. ("\n%dx %s: "):format(k, spec.name)
                        .. ABILITY.preview(spec.art.art_ability,
                                           self:getOwner(), inputs)
                        .. "\n"
      end
    --  local ability, cost = activation.ability, activation.cost
    --  effect = effect .. ("\n\nActivate [%d exhaustion]: "):format(cost)
    end
  end
  return effect
end

return Card
