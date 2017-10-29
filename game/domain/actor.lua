
local GameElement = require 'domain.gameelement'
local DB          = require 'database'
local Card        = require 'domain.card'
local ACTION      = require 'domain.action'
local ABILITY     = require 'domain.ability'
local RANDOM      = require 'common.random'
local DEFS        = require 'domain.definitions'
local PLACEMENTS  = require 'domain.definitions.placements'
local PACK        = require 'domain.pack'

local Actor = Class{
  __includes = { GameElement }
}

local BASE_ACTIONS = {
  IDLE = true,
  MOVE = true,
  INTERACT = true,
  DRAW_NEW_HAND = true,
  STASH_CARD = true,
  CONSUME_CARD = true,
  RECEIVE_PACK = true,
  CONSUME_CARDS_FROM_BUFFER = true,
}

--[[ Setup methods ]]--

function Actor:init(spec_name)

  GameElement.init(self, 'actor', spec_name)

  self.behavior = require('domain.behaviors.' .. self:getSpec 'behavior')

  self.body_id = nil
  self.cooldown = DEFS.TIME_UNIT
  self.actions = setmetatable({ PRIMARY = self:getSpec('primary') },
                              { __index = BASE_ACTIONS })


  self.equipped = {}
  for placement in ipairs(PLACEMENTS) do
    self.equipped[placement] = false
  end

  self.widgets = {}
  self.hand = {}
  self.hand_limit = 5
  self.upgrades = {
    ATH = 0,
    ARC = 0,
    MEC = 0,
    SPD = 0,
  }
  self.exp = 0
  self.playpoints = 10
  self.pack = nil

  self.buffer = {}

end

function Actor:loadState(state)
  self.cooldown = state.cooldown
  self.body_id = state.body_id
  self:setId(state.id)
  self.exp = state.exp
  self.playpoints = state.playpoints
  self.upgrades = state.upgrades
  self.hand_limit = state.hand_limit
  self.equipped = state.equipped
  self.hand = {}
  for _,card_state in ipairs(state.hand) do
    local card = Card(card_state.specname)
    card:loadState(card_state)
    table.insert(self.hand, card)
  end
  self.widgets = {}
  for index, card_state in pairs(state.widgets) do
    if card_state then
      local card = Card(card_state.specname)
      card:loadState(card_state)
      self.widgets[index] = card
    end
  end
  self.buffer = {}
  for i,card_state in ipairs(state.buffer) do
    local card = DEFS.DONE
    if card_state ~= card then
      card = Card(state.buffer.specname)
      card:loadState(card_state)
    end
    self.buffer[i] = card
  end
end

function Actor:saveState()
  local state = {}
  state.specname = self.specname
  state.cooldown = self.cooldown
  state.body_id = self.body_id
  state.id = self.id
  state.exp = self.exp
  state.playpoints = self.playpoints
  state.upgrades = self.upgrades
  state.equipped = self.equipped
  state.hand_limit = self.hand_limit
  state.hand = {}
  for _,card in ipairs(self.hand) do
    local card_state = card:saveState()
    table.insert(state.hand, card_state)
  end
  state.widgets = {}
  for index, card in pairs(self.widgets) do
    if card then
      local card_state = card:saveState()
      state.widgets[index] = card_state
    end
  end
  state.buffer = {}
  for i,card in ipairs(self.buffer) do
    local card_state = DEFS.DONE
    if card ~= card_state then
      card_state = card:saveState()
    end
    state.buffer[i] = card_state
  end
  return state
end

--[[ Spec methods ]]--

function Actor:isPlayer()
  return self:getSpec('behavior') == 'player'
end

function Actor:getBasicCollection()
  return self:getSpec('collection')
end

function Actor:getExp()
  return self.exp
end

function Actor:modifyExpBy(n)
  self.exp = math.max(0, self.exp + n)
end

function Actor:getATH()
  return self:getSpec('ath') + self.upgrades.ATH
end

function Actor:upgradeATH(n)
  self.upgrades.ATH = self.upgrades.ATH + n
end

function Actor:getARC()
  return self:getSpec('arc') + self.upgrades.ARC
end

function Actor:upgradeARC(n)
  self.upgrades.ARC = self.upgrades.ARC + n
end

function Actor:getMEC()
  return self:getSpec('mec') + self.upgrades.MEC
end

function Actor:upgradeMEC(n)
  self.upgrades.MEC = self.upgrades.MEC + n
end

function Actor:getSPD()
  return self:getSpec('spd') + self.upgrades.SPD
end

--[[ Widget methods ]]--

function Actor:isEquipped(place)
  return place and self.equipped[place]
end

function Actor:equip(place, card)
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
    if not card:isOneTimeOnly() then
      self:addCardToBackbuffer(card)
    end
  end
  -- equip new thing on index
  self.equipped[place] = card
end

function Actor:unequip(place)
  if not place then return end
  self.equipped[place] = false
end

function Actor:hasWidgetAt(index)
  return not not self.widgets[index]
end

function Actor:removeWidget(index)
  local card = self.widgets[index]
  local placement = card:getWidgetPlacement()
  self:unequip(placement)
  table.remove(self.widgets, index)
  return card
end

function Actor:placeWidget(card)
  local placement = card:getWidgetPlacement()
  table.insert(self.widgets, card)
  self:equip(placement, card)
end

function Actor:getWidget(index)
  return index and self.widgets[index]
end

function Actor:getWidgetNameAt(index)
  local card = self.widgets[index]
  if card then return card:getName() end
end

function Actor:spendWidget(index)
  local card = self.widgets[index]
  if card then
    card:addUsages()
    if card:isSpent() then
      return self:removeWidget(index)
    end
  end
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

--[[ Action methods ]]--

function Actor:isWidget(slot)
  return type(slot) == 'string'
         and slot:match("^WIDGET/%d+$")
end

function Actor:isCard(slot)
  return type(slot) == 'string'
         and slot:match("^CARD/%d+$")
end

function Actor:getSignature()
  return DB.loadSpec("action", self.actions.PRIMARY)
end

function Actor:setAction(name, id)
  self.actions[name] = id
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
  for i,card in ipairs(self.buffer) do
    if card:getSpecName() == specname then
      count = count + 1
    end
  end
  return count
end

function Actor:isBufferEmpty()
  return #self.buffer == 1
end

function Actor:getHandLimit()
  return self.hand_limit
end

--- Draw a card from actor's buffer
function Actor:drawCard()
  if #self.hand >= self.hand_limit then return end
  -- Empty buffer
  if self:isBufferEmpty() then return end

  local card = table.remove(self.buffer, 1)
  if card == DEFS.DONE then
    RANDOM.shuffle(self.buffer)
    table.insert(self.buffer, DEFS.DONE)
    card = table.remove(self.buffer, 1)
  end
  table.insert(self.hand, card)
  Signal.emit("actor_draw", self, card)
end

function Actor:getCard(index)
  return index and self.hand[index]
end

function Actor:getHandCard(index)
  assert(index >= 1 and index <= #self.hand)
  return index and self.hand[index]
end

function Actor:removeHandCard(index)
  assert(index >= 1 and index <= #self.hand)
  return table.remove(self.hand, index)
end

function Actor:addCardToBackbuffer(card)
  table.insert(self.buffer, card)
end

function Actor:consumeCard(card)
  --FIXME: add card rarity modifier!
  self.exp = self.exp + DEFS.CONSUME_EXP
end

function Actor:hasOpenPack()
  return not not self.pack
end

function Actor:openPack()
  assert(not self.pack)
  self.pack = PACK.open(self:getBasicCollection())
end

function Actor:iteratePack()
  assert(self.pack)
  return ipairs(self.pack)
end

function Actor:getPackCard(idx)
  assert(self.pack)
  assert(idx >= 1 and idx <= #self.pack)
  return Card(self.pack[idx])
end

function Actor:removePackCard(idx)
  assert(self.pack)
  assert(idx >= 1 and idx <= #self.pack)
  table.remove(self.pack, idx)
  if #self.pack == 0 then
    self.pack = nil
  end
end

--[[ Turn methods ]]--

function Actor:tick()
  self.cooldown = math.max(0, self.cooldown - self:getSPD())
end

function Actor:ready()
  return self:getBody():isAlive() and self.cooldown <= 0
end

function Actor:playCard(card_index)
  local card = table.remove(self.hand, card_index)
  if not card:isOneTimeOnly() and not card:isWidget() then
    self:addCardToBackbuffer(card)
  end
  return card
end

function Actor:makeAction(sector)
  local success = false
  repeat
    local action_slot, params = self:behavior(sector)
    if ACTION.exists(action_slot) then
      success = ACTION.execute(action_slot, self, sector, params)
    end
  until success
  return true
end

function Actor:spendTime(n)
  self.cooldown = self.cooldown + n
end

function Actor:rewardPP(n)
  self.playpoints = math.min(self.playpoints + n, DEFS.MAX_PP)
end

function Actor:spendPP(n)
  self.playpoints = math.max(self.playpoints - n, 0)
end

function Actor:getPP()
  return self.playpoints
end

return Actor

