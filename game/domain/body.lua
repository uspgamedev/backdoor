
local RANDOM      = require 'common.random'
local PLACEMENTS  = require 'domain.definitions.placements'
local GameElement = require 'domain.gameelement'

local Body = Class{
  __includes = { GameElement }
}

--[[ Setup methods ]]--

function Body:init(specname)

  GameElement.init(self, 'body', specname)

  self.damage = 0
  self.widgets = {}
  self.equipped = {}
  for placement in ipairs(PLACEMENTS) do
    self.equipped[placement] = false
  end
  self.upgrades = {
    DEF = 0,
    HP = 0,
  }
  self.sector_id = nil

end

function Body:loadState(state)
  self.damage = state.damage
  self.upgrades = state.upgrades
  self.sector_id = state.sector_id
  self:setId(state.id)
  self.equipped = state.equipped
  self.widgets = {}
  for index, card_state in pairs(state.widgets) do
    if card_state then
      local card = Card(card_state.specname)
      card:loadState(card_state)
      self.widgets[index] = card
    end
  end
end

function Body:saveState()
  local state = {}
  state.specname = self.specname
  state.damage = self.damage
  state.upgrades = self.upgrades
  state.sector_id = self.sector_id
  state.id = self.id
  state.equipped = self.equipped
  state.widgets = {}
  for index, card in pairs(self.widgets) do
    if card then
      local card_state = card:saveState()
      state.widgets[index] = card_state
    end
  end
  return state
end

--[[ Sector-related methods ]]--

function Body:setSector(sector_id)
  self.sector_id = sector_id
end

function Body:getSector()
  return Util.findId(self.sector_id)
end

function Body:getPos()
  return self:getSector():getBodyPos(self)
end

--[[ Attribute getter ]]--

function Body:getAttribute(which)
  return self:applyStaticOperators(which,
                                   self:getSpec(which:lower()) +
                                   self.upgrades[which])
end

--[[ Appearance methods ]]--

function Body:getAppearance()
  return self:getSpec('appearance')
end

--[[ HP methods ]]--

function Body:getHP()
  return self:getMaxHP() - self.damage
end

function Body:getMaxHP()
  return self:getAttribute('HP')
end

function Body:upgradeHP(val)
  self.upgrades.HP = self.upgrades.HP + val
end

function Body:isDead()
  return self:getHP() <= 0
end

function Body:isAlive()
  return not self:isDead()
end

function Body:setHP(hp)
  self.damage = math.max(0, math.min(self:getMaxHP() - hp, self:getMaxHP()))
end

--[[ DEF methods ]]--

function Body:getDEF()
  return self:getAttribute('DEF')
end

function Body:getBaseDEF()
  return self:getSpec('def_die')
end

function Body:upgradeDEF(val)
  self.upgrades.DEF = self.upgrades.DEF + val
end

--[[ Widget methods ]]--

function Body:isEquipped(place)
  return place and self.equipped[place]
end

function Body:equip(place, card)
  if not place then return end
  -- check if placement is being used
  -- if it is, then remove card from that slot
  if self:isEquipped(place) then
    local index
    for i,widget in ipairs(self.widgets) do
      if widget == self.equipped[place] then
        index = i
        break
      end
    end
    local card = self:removeWidget(index)
    local owner = card:getOwner()
    if owner and not card:isOneTimeOnly() then
      owner:addCardToBackbuffer(card)
    end
  end
  -- equip new thing on index
  self.equipped[place] = card
end

function Body:unequip(place)
  if not place then return end
  self.equipped[place] = false
end

function Body:hasWidgetAt(index)
  return not not self.widgets[index]
end

function Body:removeWidget(index)
  local card = self.widgets[index]
  local placement = card:getWidgetPlacement()
  self:unequip(placement)
  table.remove(self.widgets, index)
  return card
end

function Body:placeWidget(card)
  local placement = card:getWidgetPlacement()
  table.insert(self.widgets, card)
  self:equip(placement, card)
end

function Body:getWidget(index)
  return index and self.widgets[index]
end

function Body:getWidgetNameAt(index)
  local card = self.widgets[index]
  if card then return card:getName() end
end

function Body:spendWidget(index)
  local card = self.widgets[index]
  if card then
    card:addUsages()
    if card:isSpent() then
      return self:removeWidget(index)
    end
  end
end

function Body:eachWidget()
  return ipairs(self.widgets)
end

function Body:getWidgetCount()
  return #self.widgets
end

local _OPS = {
  ['+'] = function (a,b) return a+b end,
  ['-'] = function (a,b) return a-b end,
  ['*'] = function (a,b) return a*b end,
  ['/'] = function (a,b) return a/b end,
}

function Body:applyStaticOperators(attr, value)
  for _,widget in ipairs(self.widgets) do
    for _,operator in widget:getStaticOperators() do
      if operator.attr == attr then
        value = _OPS[operator.op](value, operator.val)
      end
    end
  end
  return value
end

function Body:triggerWidgets(kind)
  for index,widget in ipairs(self.widgets) do
    if widget:getWidgetTrigger() == kind then
      self:spendWidget(index)
    end
  end
end

--[[ Combat methods ]]--

function Body:takeDamage(amount)
  local defroll = RANDOM.rollDice(self:getDEF(), self:getBaseDEF())
  local dmg = math.max(math.min(1, amount), amount - defroll)
  -- this calculus above makes values below the minimum stay below the minimum
  -- this is so immunities and absorb resistances work with multipliers
  self.damage = math.min(self:getMaxHP(), self.damage + dmg)
end

function Body:heal(amount)
  self.damage = math.max(0, self.damage - amount)
end

return Body

