
local RANDOM      = require 'common.random'
local ABILITY     = require 'domain.ability'
local TRIGGERS    = require 'domain.definitions.triggers'
local PLACEMENTS  = require 'domain.definitions.placements'
local APT         = require 'domain.definitions.aptitude'
local ATTR        = require 'domain.definitions.attribute'
local DB          = require 'database'
local GameElement = require 'domain.gameelement'
local Util        = require "steaming.util"
local Class       = require "steaming.extra_libs.hump.class"
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
  self.armor = 0
  self.widgets = {}
  self.equipped = {}
  for placement in ipairs(PLACEMENTS) do
    self.equipped[placement] = false
  end
  self.sector_id = nil
end

function Body:loadState(state)
  self:setId(state.id or self.id)
  self:setSubtype(self.spectype)
  self.damage = state.damage or self.damage
  self.armor = state.armor or self.armor
  self.killer = state.killer or false
  self.attr_lv = {}
  self.sector_id = state.sector_id or self.sector_id
  self.widgets = state.widgets and {} or self.widgets
  for index, card_state in pairs(state.widgets) do
    if card_state then
      local card = Card(card_state.specname)
      card:loadState(card_state)
      self.widgets[index] = card
    end
  end
  local equipped = self.equipped
  if state.equipped then
    equipped = {}
    for _,placement in ipairs(PLACEMENTS) do
      equipped[placement] = self.widgets[state.equipped[placement]]
    end
  end
  self.equipped = equipped
end

function Body:saveState()
  local state = {}
  state.id = self:getId()
  state.specname = self.specname
  state.damage = self.damage
  state.armor = self.armor
  state.killer = self.killer
  state.sector_id = self.sector_id
  local equipped = {}
  for _,placement in ipairs(PLACEMENTS) do
    local equip = self:getEquipmentAt(placement)
    if equip then
      local index = self:findWidget(equip)
      equipped[placement] = index
    end
  end
  state.equipped = equipped
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

function Body:getActor()
  return self:getSector():getActorFromBody(self)
end

function Body:getPos()
  return self:getSector():getBodyPos(self)
end

--[[ Attribute getters ]]--

function Body:getWithMod(which, value)
  return math.max(1, self:applyStaticOperators(which, value))
end

function Body:getAptitude(which)
  return self:getSpec(which:lower())
end

function Body:getAttribute(which)
  local actor = self:getActor()
  local inf   = ATTR.INFLUENCE[which]
  local base  = actor and (2 * actor:getAttribute(inf[1]) +
                           1 * actor:getAttribute(inf[2])) / 3
                       or 1
  return self:getWithMod(which, base)
end

function Body:getDEF()
  return self:getAttribute('DEF')
end

function Body:getEFC()
  return self:getAttribute('EFC')
end

function Body:getVIT()
  return self:getAttribute('VIT')
end

function Body:getRES()
  return self:getAptitude('RES')
end

function Body:getFIN()
  return self:getAptitude('FIN')
end

function Body:getCON()
  return self:getAptitude('CON')
end

function Body:getBlockChance()
  return APT.BLOCKCHANCE(self:getDEF(), self:getFIN())
end

function Body:getConsumption()
  return 1
end

function Body:getMaxHP()
  return APT.HP(self:getVIT(), self:getRES())
end

--[[ Appearance methods ]]--

function Body:getAppearance()
  return self:getSpec('appearance')
end

--[[ Faction methods ]]--

function Body:getFaction()
  return self:getSpec('faction')
end

--[[ Drops methods ]]--

function Body:getDrops()
  return self:getSpec('drops') or {}
end


--[[ HP methods ]]--

function Body:getHP()
  return self:getMaxHP() - self.damage
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

--[[ Widget methods ]]--

function Body:getEquipmentAt(place)
  return place and self.equipped[place]
end

function Body:equip(place, card)
  if not place then return end
  -- check if placement is being used
  -- if it is, then remove card from that slot
  if self:getEquipmentAt(place) then
    local index
    for i,widget in ipairs(self.widgets) do
      if widget == self.equipped[place] then
        index = i
        break
      end
    end
    self:removeWidget(index)
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
  coroutine.yield('report', {
    type = 'widget_removed',
    body = self,
    widget_card = card
  })
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

function Body:findWidget(target)
  for index, widget in self:eachWidget() do
    if widget == target then
      return index
    end
  end
  return -1
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

function Body:getArmor()
  return self.armor
end

function Body:gainArmor(amount)
  amount = math.max(0, amount)
  self.armor = self.armor + amount
  return amount
end

function Body:removeAllArmor()
  self.armor = 0
end

function Body:takeDamageFrom(amount, source)
  local blocked = false
  if RANDOM.generate(100) <= self:getBlockChance() then
    amount = math.floor(amount/2)
    blocked = true
  end
  local absorbed = math.min(amount, self.armor)
  self.armor = self.armor - absorbed -- should never go negative
  local dmg = math.max(0, amount - absorbed)
  self.damage = math.min(self:getMaxHP(), self.damage + dmg)
  self.killer = source:getId()
  self:triggerWidgets(TRIGGERS.ON_HIT)
  return { dmg = dmg, blocked = blocked }
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
  local olddamage = self.damage
  self.damage = math.max(0, self.damage - amount)
  return olddamage - self.damage
end

function Body:getKiller()
  return self.killer
end

--Dialogue methods

function Body:getDialogue()
  return self:getSpec('dialogue')
end

return Body

