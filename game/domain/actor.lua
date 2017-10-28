
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
  for _,slot in pairs(DEFS.WIDGETS) do
    self.widgets[slot] = false
  end
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
  for slot, card_state in pairs(state.widgets) do
    if card_state then
      local card = Card(card_state.specname)
      card:loadState(card_state)
      self.widgets[slot] = card
    else
      self.widgets[slot] = false
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
  for slot, card in pairs(self.widgets) do
    if card then
      local card_state = card:saveState()
      state.widgets[slot] = card_state
    else
      state.widgets[slot] = false
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

function Actor:isEquipped(place)
  if not place then return end
  return self.equipped[place]
end

function Actor:equip(place, slot)
  if not place then return end
  -- check if placement is being used
  -- if it is, then remove card from that slot
  local equipped_slot = self:isEquipped(place)
  if equipped_slot then self:clearSlot(equipped_slot) end
  -- equip new thing on slot
  self.equipped[place] = slot
end

function Actor:unequip(place)
  if not place then return end
  self.equipped[place] = false
end

function Actor:isSlotOccupied(slot)
  return not not self.widgets[slot]
end

function Actor:clearSlot(slot)
  local card = self.widgets[slot]
  local placement = card:getWidgetPlacement()
  self:unequip(placement)
  self.widgets[slot] = false
  return card
end

function Actor:setSlot(slot, card)
  if self:isSlotOccupied(slot) then
    local card = self:clearSlot(slot)
    if not card:isOneTimeOnly() then
      self:addCardToBackbuffer(card)
    end
  end
  local placement = card:getWidgetPlacement()
  self:equip(placement, slot)
  self.widgets[slot] = card
end

function Actor:getWidget(slot)
  return self.widgets[slot]
end

function Actor:getWidgetNameAt(slot)
  local card = self.widgets[slot]
  if card then return card:getName() end
end

function Actor:spendWidget(slot)
  local card = self.widgets[slot]
  if card then
    card:addUsages()
    if card:isSpent() then
      return self:clearSlot(slot)
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
         and slot:match("^WIDGET_")
end

function Actor:isCard(slot)
  return type(slot) == 'number'
end

function Actor:getSignature()
  return self.actions.PRIMARY
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
  return self.hand[index]
end

function Actor:getHandCard(index)
  assert(index >= 1 and index <= #self.hand)
  return self.hand[index]
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

local function _interact(self)
  local action, params
  local sector = self:getBody():getSector()
  local i, j = self:getPos()
  local id, exit = sector:findExit(i, j, true)
  if id then
    action = 'CHANGE_SECTOR'
    params = { sector = exit.id, pos = exit.target_pos }
  end
  return action, params
end

function Actor:getAction(slot)
  if self.actions[slot] then
    if slot == 'PRIMARY' then
      return self.actions[slot]
    elseif slot == 'INTERACT' then
      return _interact(self)
    else
      return slot
    end
  elseif self.widgets[slot] then
    return self.widgets[slot]:getWidgetAbility()
  elseif self:isCard(slot) then
    local card = self.hand[slot]
    local card_type
    if card then
      if card:isArt() then
        return true
      elseif card:isUpgrade() then
        card_type = "UPGRADE"
      elseif card:isWidget() then
        card_type = "WIDGET"
      end
      return 'PLAY_'..card_type..'_CARD', {
        card_index = slot
      }
    end
  end
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
    local check, extra = self:getAction(action_slot)
    params = params or {}
    if extra then
      -- merge extra onto params
      for k,v in pairs(extra) do
        params[k] = v
      end
    end
    if check then
      local card = self:getCard(action_slot)
      local widget = self:getWidget(action_slot)
      if card and card:isArt() then
        success = ACTION.castArt(action_slot, actor, sector, params)
      elseif widget then
        success = ACTION.activateWidget(action_slot, actor, sector, params)
      elseif action_slot == 'PRIMARY' then
        success = ACTION.useSignature(actor, sector, params)
      elseif DEFS.BASIC_ABILITIES[action_slot] then
        success = ACTION.useBasicAblity(action_slot, actor, sector, params)
      else
        success = ACTION.makeManeuver(action_slot, actor, sector, params)
      end
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

