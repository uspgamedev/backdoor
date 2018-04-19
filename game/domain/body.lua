
local RANDOM      = require 'common.random'
local ABILITY     = require 'domain.ability'
local TRIGGERS    = require 'domain.definitions.triggers'
local PLACEMENTS  = require 'domain.definitions.placements'
local APT         = require 'domain.definitions.aptitude'
local DB          = require 'database'
local GameElement = require 'domain.gameelement'

local Card        = require 'domain.card'

local _EMPTY = {}

local Body = Class{
  __includes = { GameElement }
}

--[[ Setup methods ]]--

function Body:init(specname)

  GameElement.init(self, 'body', specname)

  self.killer = false
  self.damage = 0
  self.widgets = {}
  self.equipped = {}
  for placement in ipairs(PLACEMENTS) do
    self.equipped[placement] = false
  end
  self.upgrades = {
    DEF = 100,
    VIT = 100,
  }
  self.attr_lv = {
    DEF = 0,
    VIT = 0,
  }
  self.sector_id = nil

  self:updateAttr('DEF')
  self:updateAttr('VIT')
end

function Body:loadState(state)
  self.damage = state.damage
  self.killer = state.killer
  self.upgrades = state.upgrades
  self.attr_lv = {}
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
  self:updateAttr('DEF')
  self:updateAttr('VIT')
end

function Body:saveState()
  local state = {}
  state.specname = self.specname
  state.damage = self.damage
  state.killer = self.killer
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

--[[ Spec-related methods ]]--

function Body:isSpec(specname)
  if not specname then
    return true
  end
  local actual_specname = self:getSpecName()
  local ok = false
  repeat
    local parent = DB.loadSpec('body', actual_specname)['extends']
    if actual_specname == specname then
      ok = true
      break
    end
    actual_specname = parent
  until not parent
  return ok
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

function Body:getAttrLevel(which)
  return self.attr_lv[which]
end

function Body:getAttribute(which)
  return math.max(1,self:applyStaticOperators(which, self:getAttrLevel(which)))
end

function Body:updateAttr(which)
  self.attr_lv[which] = APT.ATTR_LEVEL(self, which)
end

function Body:upgradeAttr(which, amount)
  self.upgrades[which] = self.upgrades[which] + amount
  self:updateAttr(which)
end

--[[ Appearance methods ]]--

function Body:getAppearance()
  return self:getSpec('appearance')
end

--[[ Faction methods ]]--

function Body:getFaction()
  return self:getSpec('faction')
end

--[[ HP methods ]]--

function Body:getVIT()
  return self:getAttribute('VIT')
end

function Body:getHP()
  return self:getMaxHP() - self.damage
end

function Body:getMaxHP()
  return APT.VIT2HP(self:getAttribute('VIT'))
end

function Body:upgradeVIT(val)
  self:upgradeAttr('VIT', val)
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
  self:upgradeAttr('DEF', val)
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
    if owner then
      if not card:isOneTimeOnly() then card:resetUsages() end
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
  local owner = card:getOwner()
  self:triggerOneWidget(index, TRIGGERS.ON_LEAVE)
  self:unequip(placement)
  table.remove(self.widgets, index)
  if owner and not card:isOneTimeOnly() then
    card:resetUsages()
    owner:addCardToBackbuffer(card)
  end
  return card
end

function Body:placeWidget(card)
  local placement = card:getWidgetPlacement()
  self:equip(placement, card)
  table.insert(self.widgets, card)
  card:resetTicks()
  return self:triggerOneWidget(#self.widgets, TRIGGERS.ON_PLACE)
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
  end
end

function Body:eachWidget()
  return ipairs(self.widgets)
end

function Body:getWidgetCount()
  return #self.widgets
end

local floor = math.floor
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
        value = floor(_OPS[operator.op](value, operator.val))
      end
    end
  end
  return value
end

function Body:hasStatusTag(tag)
  for _,widget in ipairs(self.widgets) do
    if widget:hasStatusTag(tag) then
      return true
    end
  end
end

function Body:tick()
  self:triggerWidgets(TRIGGERS.ON_TICK)
  local spent = {}
  for i,widget in ipairs(self.widgets) do
    if widget:tick() then
      self:triggerOneWidget(i, TRIGGERS.ON_CYCLE)
    end
    if widget:isSpent() then
      table.insert(spent, i)
    end
  end
  for n,i in ipairs(spent) do
    local index = i - n + 1
    self:triggerOneWidget(index, TRIGGERS.ON_DONE)
    self:removeWidget(index)
  end
end

function Body:triggerWidgets(trigger, params)
  for index in self:eachWidget() do
    self:triggerOneWidget(index, trigger, params)
  end
end

function Body:triggerOneWidget(index, trigger, inputs)
  local widget = self:getWidget(index)
  local owner = widget:getOwner()
  inputs = inputs or {}
  inputs.widget_self = widget
  inputs.body_self = self
  inputs.pos_self = {self:getPos()}
  if widget:getWidgetTrigger() == trigger then
    local condition = widget:getWidgetTriggerCondition()
    if not condition
        or ABILITY.checkInputs(condition, owner, inputs) then
      self:spendWidget(index)
    end
  end
  local triggered_ability = widget:getWidgetTriggeredAbility() or _EMPTY
  if triggered_ability.trigger == trigger then
    local ability = triggered_ability.ability
    if ability then
      if ABILITY.checkInputs(ability, owner, inputs) then
        ABILITY.execute(ability, owner, inputs)
      end
    end
  end
end

--[[ Combat methods ]]--

function Body:takeDamageFrom(amount, source)
  local defroll = RANDOM.rollDice(self:getDEF(), self:getBaseDEF())
  local dmg = math.max(math.min(1, amount), amount - defroll)
  -- this calculus above makes values below the minimum stay below the minimum
  -- this is so immunities and absorb resistances work with multipliers
  self.damage = math.min(self:getMaxHP(), self.damage + dmg)
  self.killer = source:getId()
  self:triggerWidgets(TRIGGERS.ON_HIT)
  return dmg
  -- print damage formula info (uncomment for debugging)
  --[[
  local str = "%s is being attacked with %d damage!\n"
              .. "> %s rolls %dd%d for %d defense points!\n"
              .. "> %s takes %d in damage!\n"
  local name = self:getSpec('name')
  print(str:format(name, amount, name, self:getDEF(), self:getBaseDEF(),
                   defroll, name, dmg))
  --]]--
end

function Body:loseLifeFrom(amount, source)
  self.damage = math.min(self:getMaxHP(), self.damage + amount)
  self.killer = source:getId()
  return amount
end

function Body:exterminate()
  self.damage = self:getMaxHP()
end

function Body:heal(amount)
  self.damage = math.max(0, self.damage - amount)
end

function Body:getKiller()
  return self.killer
end

--POWERLEVEL--
function Body:getPowerLevel()
  local lvl = 0
  for attr,value in pairs(self.upgrades) do
    lvl = value + lvl
  end
  return lvl
end

return Body

