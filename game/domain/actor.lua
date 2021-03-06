
-- luacheck: no self

local GameElement = require 'domain.gameelement'
local DB          = require 'database'
local Card        = require 'domain.card'
local ACTION      = require 'domain.action'
local ABILITY     = require 'domain.ability'
local RANDOM      = require 'common.random'
local DEFS        = require 'domain.definitions'

local ACTIONDEFS  = require 'domain.definitions.action'
local VISIBILITY  = require 'common.visibility'
local Util        = require "steaming.util"
local Class       = require "steaming.extra_libs.hump.class"

local math = require 'common.math'

local Actor = Class{
  __includes = { GameElement }
}

--[[ Setup methods ]]--

function Actor:init(spec_name)

  GameElement.init(self, 'actor', spec_name)

  self.behavior = require('domain.behaviors.' .. self:getSpec 'behavior')

  self.body_id = nil
  self.energy = DEFS.ACTION.EXHAUSTION_UNIT

  self.hand = {}
  self.focus = DEFS.ACTION.MAX_FOCUS
  self.upgrades = {
    COR = DEFS.ATTR.INITIAL_UPGRADE,
    ARC = DEFS.ATTR.INITIAL_UPGRADE,
    ANI = DEFS.ATTR.INITIAL_UPGRADE,
  }
  self.training = {
    COR = 1,
    ARC = 1,
    ANI = 1
  }
  self.attr_lv = {
    COR = 0,
    ARC = 0,
    ANI = 0,
  }
  self.exp = 0
  self.playpoints = DEFS.MAX_PP

  self.fov = {}
  self.fov_range = self:getSpec('fov_range')

  self.buffer = {}
  self.prizes = {}

  self:updateAttr('COR')
  self:updateAttr('ARC')
  self:updateAttr('ANI')
end

function Actor:loadState(state)
  self:setId(state.id or self.id)
  self:setSubtype(self.spectype)
  self.energy = state.energy or self.energy
  self.body_id = state.body_id or self.body_id
  self.exp = state.exp or self.exp
  self.playpoints = state.playpoints or self.playpoints
  self.upgrades = state.upgrades or self.upgrades
  self.training = state.training or self.training
  self.attr_lv = {}
  self.prizes = state.prizes or self.prizes
  self.focus = state.focus or self.focus
  self.hand = state.hand and {} or self.hand
  for _,card_state in ipairs(state.hand) do
    local card = Card(card_state.specname)
    card:loadState(card_state)
    if not card.owner_id then
      card:setOwner(self)
    end
    table.insert(self.hand, card)
  end
  self.buffer = state.buffer and {} or self.buffer
  for i,card_state in ipairs(state.buffer) do
    local card = DEFS.DONE
    if card_state ~= card then
      card = Card(state.buffer.specname)
      card:loadState(card_state)
      if not card.owner_id then
        card:setOwner(self)
      end
    end
    self.buffer[i] = card
  end
  self.fov = state.fov or self.fov
  self:updateAttr('COR')
  self:updateAttr('ARC')
  self:updateAttr('ANI')
end

function Actor:saveState()
  local state = {}
  state.id = self:getId()
  state.specname = self.specname
  state.energy = self.energy
  state.body_id = self.body_id
  state.exp = self.exp
  state.playpoints = self.playpoints
  state.upgrades = self.upgrades
  state.training = self.training
  state.prizes = self.prizes
  state.focus = self.focus
  state.hand = {}
  for _,card in ipairs(self.hand) do
    local card_state = card:saveState()
    table.insert(state.hand, card_state)
  end
  state.buffer = {}
  for i,card in ipairs(self.buffer) do
    local card_state = DEFS.DONE
    if card ~= card_state then
      card_state = card:saveState()
    end
    state.buffer[i] = card_state
  end
  state.fov = self.fov
  return state
end

--[[ Spec methods ]]--

function Actor:getTitle()
  return ("%s %s"):format(self:getSpec('name'), self:getBody():getSpec('name'))
end

function Actor:isPlayer()
  return self:getSpec('behavior') == 'player'
end

function Actor:getBasicCollection()
  return self:getSpec('collection')
end

function Actor:getExp()
  return self.exp
end

function Actor:getEnergy()
  return self.energy
end

function Actor:modifyExpBy(n)
  self.exp = math.max(0, self.exp + n)
end

function Actor:getAptitude(which)
  return self:getSpec(which:lower())
end

--[[ Attribute and co methods ]]--

function Actor:getAttrLevel(which)
  return self.attr_lv[which]
end

function Actor:getWithMod(which, value)
  return math.max(1, self:getBody():applyStaticOperators(which, value))
end

function Actor:getAttribute(which)
  return self:getWithMod(which, self:getAttrLevel(which))
end

function Actor:getSecondaryAttribute(which)
  local inf   = DEFS.ATTR.INFLUENCE[which]
  local base  = (2 * self:getAttribute(inf[1]) +
                 1 * self:getAttribute(inf[2])) / 3
  return self:getWithMod(which, base)
end

function Actor:getSKL()
  return self:getSecondaryAttribute('SKL')
end

function Actor:getSPD()
  return self:getSecondaryAttribute('SPD')
end

function Actor:getVIT()
  return self:getSecondaryAttribute('VIT')
end

function Actor:getSpeed()
  return DEFS.APT.SPEED(self:getSPD())
end

function Actor:getFocusRegen()
  return DEFS.APT.FOCUS_REGEN(self:getSKL())
end

function Actor:getExtraHP()
  return DEFS.APT.EXTRA_HP(self:getPowerLevel(), self:getVIT())
end

function Actor:getAttrUpgrade(which)
  return self.upgrades[which]
end

function Actor:updateAttr(which)
  self.attr_lv[which] = DEFS.APT.ATTR_LEVEL(self, which)
end

function Actor:trainingDistribution()
  local count = { NONE = 0, COR = 1, ARC = 1, ANI = 1 }
  for _, card in ipairs(self.hand) do
    local attr = card:getRelatedAttr()
    count[attr] = count[attr] + 1
  end
  for _, card in ipairs(self.buffer) do
    if card ~= DEFS.DONE then
      local attr = card:getRelatedAttr()
      count[attr] = count[attr] + 1
    end
  end
  local total = 1.0 * (count.COR + count.ARC + count.ANI)
  return (count.COR)/total, (count.ARC)/total,
         (count.ANI)/total
end

function Actor:upgradeAttr(which, amount)
  self.upgrades[which] = self.upgrades[which] + amount
  self:updateAttr(which)
end

function Actor:getCOR()
  return self:getAttribute('COR')
end

function Actor:upgradeCOR(n)
  self:upgradeAttr('COR', n)
end

function Actor:getARC()
  return self:getAttribute('ARC')
end

function Actor:upgradeARC(n)
  self:upgradeAttr('ARC', n)
end

function Actor:getANI()
  return self:getAttribute('ANI')
end

function Actor:upgradeANI(n)
  self:upgradeAttr('ANI', n)
end

--[[ Body methods ]]--

function Actor:setBody(body_id)
  self.body_id = body_id
end

function Actor:getBody()
  return Util.findId(self.body_id)
end

function Actor:getPos()
  return self:getBody():getPos()
end

function Actor:getSector()
  return self:getBody():getSector()
end

--[[ Card methods ]]--

function Actor:getHand()
  return self.hand
end

function Actor:getHandSize()
  return #self.hand
end

function Actor:isHandEmpty()
  return #self.hand == 0
end

function Actor:isHandFull()
  return #self.hand >= DEFS.HAND_LIMIT
end

function Actor:canPlayCard(card)
  local attr = card:getRelatedAttr()
  local level
  if attr ~= DEFS.CARD_ATTRIBUTES.NONE then
    level = self:getAttribute(attr)
  else
    level = math.max(self:getAttribute(DEFS.PRIMARY_ATTRIBUTES.COR),
                     self:getAttribute(DEFS.PRIMARY_ATTRIBUTES.ARC))
    level = math.max(self:getAttribute(DEFS.PRIMARY_ATTRIBUTES.ANI),
                     level)
  end
  return level >= card:getLevel() and
         self:getFocus() >= card:getCost()
end

function Actor:getFocus()
  return math.floor(self.focus)
end

function Actor:getBufferSize()
  for i,card in ipairs(self.buffer) do
    if card == DEFS.DONE then
      return i-1
    end
  end
end

function Actor:getBackBufferSize()
  for i,card in ipairs(self.buffer) do
    if card == DEFS.DONE then
      return #self.buffer - i
    end
  end
end

function Actor:getBackBufferCard(i)
  return self.buffer[self:getBufferSize()+1+i]
end

function Actor:getBufferCard(i)
  return self.buffer[i]
end

function Actor:removeBufferCard(i)
  assert(self.buffer[i] and self.buffer[i] ~= DEFS.DONE,
         "Invalid card index to remove")
  return table.remove(self.buffer, i)
end

function Actor:copyBackBuffer()
  local copy = {}
  for i = self:getBufferSize()+2, #self.buffer do
    table.insert(copy, self.buffer[i])
  end
  return copy
end

function Actor:countCardInBuffer(specname)
  local count = 0
  for _,card in ipairs(self.buffer) do
    if card:getSpecName() == specname then
      count = count + 1
    end
  end
  return count
end

function Actor:isBufferEmpty()
  return #self.buffer == 1
end

function Actor:copyBuffer()
  local copy = {}
  for i = 1, #self.buffer do
    if self.buffer[i] ~= DEFS.DONE then
      table.insert(copy, self.buffer[i])
    end
  end
  return copy
end

function Actor:canDrawCard()
  return self:getBufferSize() > 0 or self:getPP() > 0
end

--- Draw a card from actor's buffer
function Actor:drawCard()
  -- Empty buffer
  if self:isBufferEmpty() then return end

  if self:createEquipmentCards() then
    return
  end

  if self:canDrawCard() then
    local card = table.remove(self.buffer, 1)
    if card == DEFS.DONE then
      RANDOM.shuffle(self.buffer)
      table.insert(self.buffer, DEFS.DONE)
      coroutine.yield('report', {
        type = "shuffle_buffers",
        actor = self,
      })
      self:spendPP(1)
      card = table.remove(self.buffer, 1)
    end
    table.insert(self.hand, 1, card)
    coroutine.yield('report', {
      type = "draw_card",
      actor = self,
      card = card
    })
  end
end

function Actor:createEquipmentCards()
  local active_eqp = self:getBody():getEquipmentAt('wieldable')
  if active_eqp then
    active_eqp:addUsages()
    for _,card_spec in active_eqp:eachActiveEquipmentCards() do
      local card = Card(card_spec.card)
      card:setOwner(self)
      table.insert(self.hand, 1, card)
      coroutine.yield('report', {
        type = "create_equipment_card",
        actor = self,
        card = card,
        widget = active_eqp,
      })
    end
    return true
  end
end

function Actor:getActionCardsCount()
  local active_eqp = self:getBody():getEquipmentAt('wieldable')
  if active_eqp then
    return active_eqp:getActiveEquipmentCardCount()
  else
    return 0
  end
end

function Actor:getHandCard(index)
  return index and self.hand[index]
end

function Actor:removeHandCard(index)
  index = index or #self.hand
  assert(index >= 1 and index <= #self.hand)
  return table.remove(self.hand, index)
end

function Actor:addCardToBackbuffer(card)
  table.insert(self.buffer, card)
end

function Actor:consumeCard(card) -- luacheck: no unused
  --FIXME: add card rarity modifier!
  local cor, arc, ani = self:trainingDistribution()
  local xp = DEFS.CONSUME_EXP
  local round = math.round
  self:upgradeCOR(round(cor*xp))
  self:upgradeARC(round(arc*xp))
  self:upgradeANI(round(ani*xp))
  self.exp = self.exp + xp
  coroutine.yield('report', {
    body = self:getBody(),
    sfx = 'upgrade'
  })
end

function Actor:addPrizePack(collection)
  table.insert(self.prizes, collection)
end

function Actor:getPrizePacks()
  return self.prizes
end

function Actor:getNextPrizePack()
  return #self.prizes > 0 and table.remove(self.prizes, 1)
end

function Actor:removePrizePack(index)
  if self.prizes[index] then table.remove(self.prizes,index) end
end

function Actor:removeAllPacks()
  self.prizes = {}
end

function Actor:getPrizePackCount()
  return #self.prizes
end

-- VISIBILITY Methods --

function Actor:getVisibleBodies()
  local seen = {}
  local sector = self:getSector()

  local range = self:getFovRange()
  local pi, pj = self:getPos()
  for i = pi-range, pi+range do
    for j = pj-range, pj+range do
      if sector:isInside(i, j) then
        local body = sector:getBodyAt(i, j)
        local fov = self:getFov(sector)
        local visible = fov and fov[i] and fov[i][j]
        if body and body ~= self:getBody() and visible and visible ~= 0 then
          seen[body:getId()] = true
        end
      end
    end
  end

  return seen
end

function Actor:canSee(target)
  local sector = self:getSector()
  local target_sector = target:getSector()
  if sector ~= target_sector then
    return false
  end
  local i, j = target:getPos()
  if not i or not j then
    return false
  end
  return self:canSeePosition(i, j)
end

function Actor:canSeePosition(i, j)
  local fov = self:getFov(self:getSector())
  local visible = fov[i][j]
  return visible and visible > 0
end

function Actor:getHostileBodies()
  local visible_bodies = self:getVisibleBodies()
  local hostile_bodies = {}
  local actor_body_faction = self:getBody():getFaction()
  for body_id in pairs(visible_bodies) do
    local body = Util.findId(body_id)
    local faction = body:getFaction()
    if faction ~= actor_body_faction and faction ~= "inert" then
      table.insert(hostile_bodies, body)
    end
  end
  return hostile_bodies
end

function Actor:getBodiesInFactions(factions)
  local visible_bodies = self:getVisibleBodies()
  local result = {}
  for body_id in pairs(visible_bodies) do
    local body = Util.findId(body_id)
    local faction = body:getFaction()
    for _, queried in ipairs(factions) do
      if faction == queried then
        table.insert(result, body)
      end
    end
  end
  return result
end

function Actor:getVisibleTilesIf(check)
  local seen = {}
  local n = 0
  local sector = self:getSector()

  local range = self:getFovRange()
  local pi, pj = self:getPos()
  for i = pi-range, pi+range do
    for j = pj-range, pj+range do
      if sector:isInside(i, j) then
        local fov = self:getFov(sector)
        local visible = fov and fov[i] and fov[i][j]
        if visible and visible ~= 0 and check(sector, i, j) then
          seen[n + 1] = {i, j, i = i, j = j}
        end
      end
    end
  end

  return seen
end

function Actor:purgeFov(sector)
  local fov = self:getFov(sector)
  if not fov then
    self.fov[sector:getId()] = VISIBILITY.purgeFov(sector)
  end
end

function Actor:resetFov(sector)
  VISIBILITY.resetFov(self:getFov(sector), sector)
end

function Actor:updateFov(sector)
  VISIBILITY.updateFov(self, sector)
end

function Actor:getFov(sector)
  sector = sector or self:getBody():getSector()
  return self.fov[sector:getId()]
end

function Actor:getFovRange()
  return math.max(0,self:getBody()
             :applyStaticOperators("FOV", self.fov_range))
end

--[[ Turn methods ]]--

function Actor:grabDrops(tile)
  if not tile then return end
  local drops = tile.drops
  local inputvalues = {}
  local n = #drops
  local i = 1
  while i <= n do
    local dropname = drops[i]
    local dropspec = DB.loadSpec('drop', dropname)
    inputvalues.self = self
    if ABILITY.checkInputs(dropspec.ability, self, inputvalues) then
      table.remove(drops, i)
      n = n-1
      coroutine.yield('report', {
        actor = self,
        sfx = dropspec.sfx,
      })
      ABILITY.execute(dropspec.ability, self, inputvalues)
    else
      i = i+1
    end
  end
end

function Actor:tick()
  self.energy = self.energy + self:getSpeed()
  self:gainFocus(self:getFocusRegen())
end

function Actor:ready()
  return self:getBody():isAlive() and self.energy >= ACTIONDEFS.MAX_ENERGY
end

function Actor:playCard(card_index)
  local card = self:removeHandCard(card_index)
  local attr = card:getRelatedAttr()
  if attr ~= DEFS.CARD_ATTRIBUTES.NONE then
    self.training[attr] = self.training[attr] + 1
  end
  if not card:isOneTimeOnly() and not card:isWidget() and not card:isTemporary() then
    self:addCardToBackbuffer(card)
  end
  return card
end

function Actor:discardCard(index)
  local card = self:removeHandCard(index)
  if not card:isTemporary() then
    coroutine.yield('report', {
      type = 'discard_card',
      actor = self,
      card_index = index
    })
    self:addCardToBackbuffer(card)
  else
    coroutine.yield('report', {
      type = 'discard_temporary_card',
      actor = self,
      card_index = index
    })
  end
end

function Actor:discardHand()
  while not self:isHandEmpty() do
    local index = self:getHandSize()
    self:discardCard(index)
  end
end

function Actor:beginTurn()
  while self:getHandSize() < DEFS.HAND_LIMIT and self:canDrawCard() do
    self:drawCard()
  end
end

function Actor:endTurn()
  local body = self:getBody()
  body:triggerWidgets(DEFS.TRIGGERS.ON_TURN)
end

function Actor:makeAction()
  self:updateFov(self:getBody():getSector())
  local success = false
  repeat
    local action_slot, params
    if self:getBody():hasStatusTag(DEFS.STATUS_TAGS.STUN) then
      action_slot, params = DEFS.ACTION.IDLE, {}
    else
      action_slot, params = self:behavior()
    end
    if ACTION.exists(action_slot) then
      success = ACTION.execute(action_slot, self, params)
    end
  until success
  return true
end

function Actor:exhaust(n)
  self.energy = self.energy - n * DEFS.ACTION.EXHAUSTION_UNIT
end

function Actor:spendFocus(n)
  self.focus = math.max(0, self.focus - n)
end

function Actor:gainFocus(n)
  self.focus = math.min(self.focus + n, DEFS.ACTION.MAX_FOCUS)
end

function Actor:rewardPP(n)
  self.playpoints = math.min(self.playpoints + n, DEFS.MAX_PP)
end

function Actor:spendPP(n)
  self.playpoints = math.max(self.playpoints - n, 0)
  coroutine.yield('report', {
    type = "change_pp",
    actor = self,
  })
end

function Actor:getPP()
  return self.playpoints
end

function Actor:setPP(n)
  self.playpoints = math.max(0, math.min(DEFS.MAX_PP, n))
end

function Actor:getPowerLevel()
  return DEFS.ATTR.POWER_LEVEL(self.upgrades)
end

return Actor
