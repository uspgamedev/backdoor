
local GameElement = require 'domain.gameelement'
local DB          = require 'database'
local Card        = require 'domain.card'
local ACTION      = require 'domain.action'
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
  NEW_HAND = true,
  RECALL_CARD = true,
  CONSUME_CARD = true,
  GET_PACK_CARD = true,
  CONSUME_PACK_CARD = true
}

--[[ Setup methods ]]--

function Actor:init(spec_name)

  GameElement.init(self, 'actor', spec_name)

  self.behavior = require('domain.behaviors.' .. self:getSpec 'behavior')

  self.body_id = nil
  self.cooldown = DEFS.COOLDOWN
  self.actions = setmetatable({ PRIMARY = self:getSpec('primary') },
                              { __index = BASE_ACTIONS })


  self.equipped_cards = {}
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
  self.pack = nil

  self.buffers = {}
  for i=1,DEFS.ACTOR_BUFFER_NUM do
    self.buffers[i] = {{},{}, current = 1}
  end

end

function Actor:loadState(state)
  self.cooldown = state.cooldown
  self.body_id = state.body_id
  self:setId(state.id)
  self.exp = state.exp
  self.upgrades = state.upgrades
  self.hand_limit = state.hand_limit
  self.widgets = state.widgets
  self.equipped = state.equipped
  self.hand = {}
  for _,card_state in ipairs(state.hand) do
    local card = Card(card_state.specname)
    card:loadState(card_state)
    table.insert(self.hand, card)
  end
  self.equipped_cards = {}
  for slot, card_info_state in pairs(state.equipped_cards) do
    local card = Card(card_info_state.card.specname)
    card:loadState(card_info_state.card)
    local card_info = {}
    for k, data in pairs(card_info_state) do
      card_info[k] = data
    end
    card_info.card = card
    self.equipped_cards[slot] = card_info
  end
  self.buffers = {}
  for i=1,DEFS.ACTOR_BUFFER_NUM do
    local buffer_state = state.buffers[i]
    local buffer = {}
    for j,card_name in ipairs(state.buffers[i]) do
      buffer[j] = card_name
    end
    self.buffers[i] = buffer
  end
  self.last_buffer = state.last_buffer
end

function Actor:saveState()
  local state = {}
  state.specname = self.specname
  state.cooldown = self.cooldown
  state.body_id = self.body_id
  state.id = self.id
  state.exp = self.exp
  state.upgrades = self.upgrades
  state.widgets = self.widgets
  state.equipped = self.equipped
  state.hand_limit = self.hand_limit
  state.hand = {}
  state.equipped_cards = {}
  for _,card in ipairs(self.hand) do
    local card_state = card:saveState()
    table.insert(state.hand, card_state)
  end
  for slot, card_info in pairs(self.equipped_cards) do
    local card_state = card_info.card:saveState()
    local card_info_state = {}
    for k, data in pairs(card_info) do
      card_info_state[k] = data
    end
    card_info_state.card = card_state
    state.equipped_cards[slot] = card_info_state
  end
  state.buffers = {}
  for i=1,DEFS.ACTOR_BUFFER_NUM do
    local buffer = self.buffers[i]
    local buffer_state = {}
    for k,card_name in ipairs(self.buffers[i]) do
      buffer_state[k] = card_name
    end
    state.buffers[i] = buffer_state
  end
  state.last_buffer = self.last_buffer
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

function Actor:equip(place)
  if not place then return end
  assert(not self:isEquipped(place),
         "Tried to equip widget in already used placement!")
  self.equipped[place] = true
end

function Actor:unequip(place)
  if not place then return end
  self.equipped[place] = false
end

function Actor:isSlotOccupied(slot)
  return not not self.widgets[slot]
end

function Actor:clearSlot(slot)
  local card = self.equipped_cards[slot].card
  local placement = card:getWidgetPlacement()
  self:unequip(placement)
  self.equipped_cards[slot] = false
  self.widgets[slot] = false
end

function Actor:setSlot(slot, card)
  if self:isSlotOccupied(slot) then
    self:clearSlot(slot)
  end
  local placement = card:getWidgetPlacement()
  self:equip(placement)
  self.widgets[slot] = true
  self.equipped_cards[slot] = {
    card = card,
    tick = DEFS.COOLDOWN,
    spent = 0,
  }
end

function Actor:getWidgetNameAt(slot)
  local card_info = self.equipped_cards[slot]
  if card_info then
    local card = card_info.card
    return card:getName()
  end
end

function Actor:degradeWidget(trigger, slot)
  local card_info = self.equipped_cards[slot]
  if card_info then
    local card = card_info.card
    if card:getWidgetTrigger() == trigger then
      if trigger == "on_tick" then
        card_info.tick = card_info.tick - 1
        if card_info.tick <= 0 then
          card_info.spent = card_info.spent + 1
          card_info.tick = DEFS.COOLDOWN
        end
      else
        card_info.spent = card_info.spent + 1
      end
      if card_info.spent > card:getWidgetCharges() then
        self:clearSlot(slot)
      end
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

function Actor:getAction(slot)
  if self.actions[slot] then
    if slot == 'PRIMARY' then
      return self.actions[slot]
    else
      return slot
    end
  elseif self.equipped_cards[slot] then
    local card_info = self.equipped_cards[slot]
    local card = card_info.card
    return card:getWidgetAction()
  elseif self:isCard(slot) then
    local card = self.hand[slot]
    if card then
      if card:isArt() then
        return card:getArtAction()
      elseif card:isUpgrade() then
        local cost = card:getUpgradeCost()
        if self.exp >= cost then
          return 'UPGRADE', {
            list = card:getUpgradesList(),
            ["exp-cost"] = cost
          }
        end
      elseif card:isWidget() then
        return 'PLACE_WIDGET', {
          card = card
        }
      end
    end
  end
end

function Actor:setAction(name, id)
  self.actions[name] = id
end

--[[ Card methods ]]--

function Actor:getHand()
  return self.hand
end

function Actor:isHandEmpty()
  return #self.hand == 0
end

function Actor:getBufferSize(which)
  which = which or self.last_buffer
  for i,card in ipairs(self.buffers[which]) do
    if card == DEFS.DONE then
      return i-1
    end
  end
end

function Actor:getBackBufferSize(which)
  which = which or self.last_buffer
  for i,card in ipairs(self.buffers[which]) do
    if card == DEFS.DONE then
      return #self.buffers[which] - i
    end
  end
end

function Actor:isBufferEmpty(which)
  which = which or self.last_buffer
  return #self.buffers[which] == 1
end

function Actor:getHandLimit()
  return self.hand_limit
end

--- Draw a card from actor's buffer
function Actor:drawCard(which)
  if #self.hand >= self.hand_limit then return end
  which = which or self.last_buffer
  -- Empty buffer
  if self:isBufferEmpty(which) then return end

  local card_name = self.buffers[which][1]
  table.remove(self.buffers[which], 1)
  if card_name == DEFS.DONE then
    RANDOM.shuffle(self.buffers[which])
    table.insert(self.buffers[which], DEFS.DONE)
    card_name = self.buffers[which][1]
    table.remove(self.buffers[which], 1)
  end
  local card = Card(card_name)
  table.insert(self.hand, card)
  self.last_buffer = which
  Signal.emit("actor_draw", self, card)
end

function Actor:getHandCard(index)
  assert(index >= 1 and index <= #self.hand)
  return self.hand[index]
end

function Actor:removeHandCard(index)
  assert(index >= 1 and index <= #self.hand)
  table.remove(self.hand, index)
end

function Actor:addCardToBackbuffer(card, buffer_idx)
  assert(buffer_idx >= 0 and buffer_idx <= DEFS.ACTOR_BUFFER_NUM)
  if buffer_idx == 0 then
    buffer_idx = self.last_buffer
  end
  local buffer = self.buffers[buffer_idx]
  table.insert(buffer, card:getSpecName())
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
  for _,slot in pairs(DEFS.WIDGETS) do
    self:degradeWidget("on_tick", slot)
  end
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

function Actor:makeAction(sector)
  local success = false
  repeat
    local action_slot, params = self:behavior(sector)
    local check, extra = self:getAction(action_slot)
    if extra then
      -- merge extra onto params
      for k,v in pairs(extra) do
        params[k] = v
      end
    end
    if check then
      local action
      if action_slot == 'INTERACT' then
        action, params = _interact(self)
      else
        action = check
      end
      if self:isCard(action_slot) then
        table.remove(self.hand, action_slot)
      elseif self:isWidget(action_slot) then
        self:degradeWidget("on_use", action_slot)
      end
      if action then
        success = ACTION.run(action, self, sector, params)
      end
    end
  until success
  return true
end

function Actor:spendTime(n)
  self.cooldown = self.cooldown + n
end

return Actor
