
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

local math = require 'common.math'

local Actor = Class{
  __includes = { GameElement }
}

--[[ Setup methods ]]--

function Actor:init(spec_name)

  GameElement.init(self, 'actor', spec_name)

  self.behavior = require('domain.behaviors.' .. self:getSpec 'behavior')

  self.body_id = nil
  self.cooldown = DEFS.ACTION.EXHAUSTION_UNIT

  self.hand = {}
  self.hand_limit = 5
  self.hand_countdown = 0
  self.upgrades = {
    COR = 100,
    ARC = 100,
    ANI = 100,
    SPD = 100,
  }
  self.attr_lv = {
    COR = 0,
    ARC = 0,
    ANI = 0,
    SPD = 0,
  }
  self.exp = 0
  self.playpoints = DEFS.MAX_PP

  self.fov = {}
  self.fov_range = 4

  self.buffer = {}
  self.prizes = {}

  self:updateAttr('COR')
  self:updateAttr('ARC')
  self:updateAttr('ANI')
  self:updateAttr('SPD')
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
  self.fov = state.fov or self.fov
  self:updateAttr('COR')
  self:updateAttr('ARC')
  self:updateAttr('ANI')
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
  return math.max(1,self:getBody()
                        :applyStaticOperators(which, self:getAttrLevel(which)))
end

function Actor:updateAttr(which)
  self.attr_lv[which] = DEFS.APT.ATTR_LEVEL(self, which)
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

function Actor:getSector()
  return self:getBody():getSector()
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

function Actor:isHandFull()
  return #self.hand >= self.hand_limit
end

function Actor:getHandCountdown()
  return self.hand_countdown
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
  self:resetHandCountdown()
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

function Actor:getPrizePacks()
  return self.prizes
end

function Actor:getNextPrizePack()
  return #self.prizes > 0 and table.remove(self.prizes, 1)
end

function Actor:removePrizePack(index)
  if self.prizes[index] then table.remove(self.prizes,index) end
end

function Actor:getPrizePackCount()
  return #self.prizes
end

-- Visibility Methods --

function Actor:getVisibleBodies()
  local seen = {}
  local sector = self:getSector()
  local w, h = sector:getDimensions()

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
  local fov = self:getFov(sector)
  local i, j = target:getPos()
  local visible = fov[i][j]
  return visible and visible > 0
end

function Actor:purgeFov(sector)
  local fov = self:getFov(sector)
  if not fov then
    self.fov[sector:getId()] = Visibility.purgeFov(sector)
  end
end

function Actor:resetFov(sector)
  Visibility.resetFov(self:getFov(sector), sector)
end

function Actor:updateFov(sector)
  Visibility.updateFov(self, sector)
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
  local drops = tile.drops
  local inputvalues = {}
  local n = #drops
  local i = 1
  while i <= n do
    local dropname = drops[i]
    local dropspec = DB.loadSpec('drop', dropname)
    if ABILITY.checkInputs(dropspec.ability, self, inputvalues) then
      table.remove(drops, i)
      n = n-1
      coroutine.yield('report', {
        sfx = 'get-item'
      })
      ABILITY.execute(dropspec.ability, self, inputvalues)
    else
      i = i+1
    end
  end
end

function Actor:tick()
  self.cooldown = math.max(0, self.cooldown - self:getSPD())
  if not self:isHandEmpty() then
    self.hand_countdown = math.max(0, self.hand_countdown - 1)
  else
    self.hand_countdown = 0
  end
  if self.hand_countdown == 0 then
    while not self:isHandEmpty() do
      local card = self:removeHandCard(1)
      self:addCardToBackbuffer(card)
    end
  end
end

function Actor:resetHandCountdown()
  self.hand_countdown = DEFS.ACTION.HAND_DURATION
end

function Actor:ready()
  return self:getBody():isAlive() and self.cooldown <= 0
end

function Actor:playCard(card_index)
  local card = table.remove(self.hand, card_index)
  if not card:isOneTimeOnly() and not card:isWidget() then
    self:addCardToBackbuffer(card)
  end
  self:resetHandCountdown()
  return card
end

function Actor:turn()
  self:getBody():triggerWidgets(DEFS.TRIGGERS.ON_TURN)
end

function Actor:makeAction()
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
  self:updateFov(self:getBody():getSector())
  return true
end

function Actor:exhaust(n)
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

function Actor:getPowerLevel()
  local lvl = 0
  local body_powerlvl = self:getBody():getPowerLevel()
  for attr,value in pairs(self.upgrades) do
    lvl = value + lvl
  end
  return lvl + body_powerlvl
end

return Actor
