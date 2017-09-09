
local GameElement = require 'domain.gameelement'
local ACTION      = require 'domain.action'
local Card        = require 'domain.card'
local RANDOM      = require 'common.random'

local Actor = Class{
  __includes = { GameElement }
}

function Actor:init(spec_name)

  GameElement.init(self, 'actor', spec_name)

  self.behavior = require('domain.behaviors.' .. self:getSpec 'behavior')

  self.body_id = nil
  self.cooldown = 10
  self.actions = {
    IDLE = true,
    MOVE = true,
    INTERACT = true,
    PRIMARY = "SHOOT"
  }

  self.hand = {}
  self.hand_limit = 7

end

function Actor:loadState(state)
  self.cooldown = state.cooldown
  self.actions = state.actions
  self.body_id = state.body_id
  self:setId(state.id)
  self.hand_limit = state.hand_limit
  self.hand = {}
  for _,card_state in ipairs(state.hand) do
    local card = Card(card_state.specname)
    card:loadState(card_state)
    table.insert(self.hand, card)
  end
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
    return self.actions[slot]
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
  else
    -- FIXME: actor wastes time when interacting with nothing!
    action = 'IDLE'
  end
  return action, params
end

function Actor:makeAction(sector)
  local action_slot, params = self:behavior(sector)
  local check = self:getAction(action_slot)
  if check then
    local action
    if check == true then
      if action_slot == 'INTERACT' then
        action, params = _interact(self)
      else
        action = action_slot
      end
    else
      action = check
    end
    if self:isCard(action_slot) then
      table.remove(self.hand, action_slot)
    end
    return ACTION.run(action, self, sector, params)
  end
end

function Actor:spendTime(n)
  self.cooldown = self.cooldown + n
end

--Draw a card from actor's buffer
function Actor:drawCard()
  if #self.hand >= self.hand_limit then return end

  --TODO: Change this so actor draws from his buffer
  local card
  local roll = RANDOM.generate()
  if roll > .5 then
    card = Card("bolt")
  elseif roll > .3 then
    card = Card("cure")
  else
    card = Card("draw")
  end
  table.insert(self.hand, card)
  Signal.emit("actor_draw", self, card)

end

return Actor

