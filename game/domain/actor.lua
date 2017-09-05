
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

function Actor:setBody(body_id)
  self.body_id = body_id
end

function Actor:getBody()
  return Util.findId(self.body_id)
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

function Actor:makeAction(sector)
  local action_slot, params = self:behavior(sector)
  local check = self:getAction(action_slot)
  if check then
    local action
    if check == true then
      action = action_slot
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
  if RANDOM.generate() >.5 then
    card = Card("dummy")
  else
    card = Card("dummy2")
  end
  table.insert(self.hand, card)
  Signal.emit("actor_draw", self, card)

end

return Actor

