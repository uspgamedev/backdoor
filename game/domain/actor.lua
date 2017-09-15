
local GameElement = require 'domain.gameelement'
local ACTION      = require 'domain.action'
local Card        = require 'domain.card'
local RANDOM      = require 'common.random'
local DEFS        = require 'domain.definitions'

local Actor = Class{
  __includes = { GameElement }
}

local BASE_ACTIONS = {
  IDLE = true,
  MOVE = true,
  INTERACT = true,
  NEW_HAND = true,
  RECALL_CARD = true,
  CONSUME_CARD = true
}

function Actor:init(spec_name)

  GameElement.init(self, 'actor', spec_name)

  self.behavior = require('domain.behaviors.' .. self:getSpec 'behavior')

  self.body_id = nil
  self.cooldown = 10
  self.actions = setmetatable({ PRIMARY = "SHOOT" }, { __index = BASE_ACTIONS })

  self.hand = {}
  self.hand_limit = 5

  self.buffers = {}
  for i=1,3 do
    self.buffers[i] = {{},{}, current = 1}
  end

end

function Actor:loadState(state)
  self.cooldown = state.cooldown
  self.actions = setmetatable(state.actions, { __index = BASE_ACTIONS })
  self.body_id = state.body_id
  self:setId(state.id)
  self.hand_limit = state.hand_limit
  self.hand = {}
  for _,card_state in ipairs(state.hand) do
    local card = Card(card_state.specname)
    card:loadState(card_state)
    table.insert(self.hand, card)
  end
  self.buffers = {}
  for i=1,3 do
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
  state.actions = self.actions
  state.body_id = self.body_id
  state.id = self.id
  state.hand_limit = self.hand_limit
  state.hand = {}
  for _,card in ipairs(self.hand) do
    local card_state = card:saveState()
    table.insert(state.hand, card_state)
  end
  state.buffers = {}
  for i=1,3 do
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

function Actor:isPlayer()
  return self:getSpec('behavior') == 'player'
end

function Actor:setBody(body_id)
  self.body_id = body_id
end

function Actor:getBody()
  return Util.findId(self.body_id)
end

function Actor:getATH()
  return self:getSpec('ath')
end

function Actor:getARC()
  return self:getSpec('arc')
end

function Actor:getMEC()
  return self:getSpec('mec')
end

function Actor:getPos()
  return self:getBody():getPos()
end

function Actor:isWidget(slot)
  return type(slot) == 'string'
end

function Actor:isCard(slot)
  return type(slot) == 'number'
end

function Actor:getAction(slot)
  if self:isWidget(slot) then
    local action = self.actions[slot]
    if action == true then
      return slot
    else
      return action
    end
  elseif self:isCard(slot) then
    local card = self.hand[slot]
    if card and card:isArt() then
      return card:getArtAction()
    end
  end
end

function Actor:setAction(name, id)
  self.actions[name] = id
end

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

function Actor:getHandLimit()
  return self.hand_limit
end

--- Draw a card from actor's buffer
function Actor:drawCard(which)
  if #self.hand >= self.hand_limit then return end
  which = which or self.last_buffer
  -- Empty buffer
  if #self.buffers[which] == 1 then return end

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

function Actor:recallCard(index)
  assert(index >= 1 and index <= #self.hand)
  assert(self.last_buffer)
  local card = self.hand[index]
  table.remove(self.hand, index)
  local buffer = self.buffers[self.last_buffer]
  table.insert(buffer, card:getSpecName())
end

function Actor:tick()
  self.cooldown = math.max(0, self.cooldown - 1)
end

function Actor:ready()
  return self.cooldown <= 0
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
    local check = self:getAction(action_slot)
    if check then
      local action
      if action_slot == 'INTERACT' then
        action, params = _interact(self)
      else
        action = check
      end
      if self:isCard(action_slot) then
        table.remove(self.hand, action_slot)
      end
      if action then
        success = ACTION.run(action, self, sector, params)
      end
    end
  until success
end

function Actor:spendTime(n)
  self.cooldown = self.cooldown + n
end

return Actor

