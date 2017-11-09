
local GameElement = require 'domain.gameelement'
local DB          = require 'database'
local Card        = require 'domain.card'
local ACTION      = require 'domain.action'
local ABILITY     = require 'domain.ability'
local RANDOM      = require 'common.random'
local DEFS        = require 'domain.definitions'

local PLACEMENTS  = require 'domain.definitions.placements'
local PACK        = require 'domain.pack'
local Visibility  = require 'common.visibility'

local Actor = Class{
  __includes = { GameElement }
}

--[[ Setup methods ]]--

function Actor:init(spec_name)

  GameElement.init(self, 'actor', spec_name)

  self.behavior = require('domain.behaviors.' .. self:getSpec 'behavior')

  self.body_id = nil
  self.cooldown = DEFS.TIME_UNIT

  self.hand = {}
  self.hand_limit = 5
  self.upgrades = {
    ATH = 0,
    ARC = 0,
    MEC = 0,
    SPD = 0,
  }
  self.attr_lv = {
    ATH = 0,
    ARC = 0,
    MEC = 0,
    SPD = 0,
  }
  self.exp = 0
  self.playpoints = 10

  self.fov = {}
  self.fov_range = 8

  self.buffer = {}
  self.prizes = {}

end

function Actor:loadState(state)
  self.cooldown = state.cooldown
  self.body_id = state.body_id
  self:setId(state.id)
  self.exp = state.exp
  self.playpoints = state.playpoints
  self.upgrades = state.upgrades
  self.attr_lv = {}
  self.prizes = state.prizes
  self.hand_limit = state.hand_limit
  self.hand = {}
  for _,card_state in ipairs(state.hand) do
    local card = Card(card_state.specname)
    card:loadState(card_state)
    if not card.owner_id then
      card:setOwner(self)
    end
    table.insert(self.hand, card)
  end
  self.buffer = {}
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
  self:updateAttr('ATH')
  self:updateAttr('ARC')
  self:updateAttr('MEC')
  self:updateAttr('SPD')
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
  state.prizes = self.prizes
  state.hand_limit = self.hand_limit
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
  return state
end

--[[ Spec methods ]]--

function Actor:isPlayer()
  return self:getSpec('behavior') == 'player'
end

function Actor:getBasicCollection()
  return self:getSpec('collection')
end

function Actor:getSignatureAbilityName()
  return self:getSpec('signature')
end

function Actor:getExp()
  return self.exp
end

function Actor:modifyExpBy(n)
  self.exp = math.max(0, self.exp + n)
end

function Actor:getAttrLevel(which)
  return self.attr_lv[which]
end

function Actor:getAttribute(which)
  return self:getBody()
             :applyStaticOperators(which, self:getAttrLevel(which))
end

function Actor:updateAttr(which)
  local lv = 0
  local required = 0
  repeat
    required = required +
               DEFS.REQUIRED_ATTR_UPGRADE(self:getSpec(which:lower()), lv)
    lv = lv + 1
    print(lv, required)
  until self.upgrades[which] < required
  self.attr_lv[which] = lv-1
end

function Actor:upgradeAttr(which, amount)
  self.upgrades[which] = self.upgrades[which] + amount
  self:updateAttr(which)
end

function Actor:getATH()
  return self:getAttribute('ATH')
end

function Actor:upgradeATH(n)
  self:upgradeAttr('ATH', n)
end

function Actor:getARC()
  return self:getAttribute('ARC')
end

function Actor:upgradeARC(n)
  self:upgradeAttr('ARC', n)
end

function Actor:getMEC()
  return self:getAttribute('MEC')
end

function Actor:upgradeMEC(n)
  self:upgradeAttr('MEC', n)
end

function Actor:getSPD()
  return self:getAttribute('SPD')
end

function Actor:upgradeSPD(n)
  self:upgradeAttr('SPD', n)
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
  return DB.loadSpec("action", self:getSignatureAbilityName())
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

function Actor:getHandCard(index)
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

function Actor:addPrizePack(collection)
  table.insert(self.prizes, collection)
end

function Actor:getNextPrizePack()
  return #self.prizes > 0 and table.remove(self.prizes, 1)
end

function Actor:purgeFov(sector)
  Visibility.purgeActorFov(self,sector)
end

function Actor:resetFov(sector)
  Visibility.resetActorFov(self,sector)
end

function Actor:updateFov(sector)
  Visibility.updateFov(self,sector)
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
  self:getBody():triggerWidgets(DEFS.TRIGGERS.ON_TURN, sector)
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
