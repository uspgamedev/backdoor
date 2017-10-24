
local FONT = require 'view.helpers.font'
local CARD = require 'view.helpers.card'
local COLORS = require 'domain.definitions.colors'


--LOCAL FUNCTIONS DECLARATIONS--

local _drawCard

--CONSTS--
local _F_NAME = "Text" --Font name
local _F_SIZE = 21 --Font size
local _ACTION_TYPES = {
  'use', 'stash', 'consume'
}

local _font

--HandView Class--

local HandView = Class{
  __includes = { ELEMENT }
}

--CLASS FUNCTIONS--

function HandView:init(route)

  ELEMENT.init(self)

  self.focus_index = -1 --What card is focused. -1 if none
  self.action_type = -1
  self.x, self.y = 100, O_WIN_H - 30
  self.initial_x, self.initial_y = self.x, self.y
  self.route = route
  self:reset()

  _font = _font or FONT.get(_F_NAME, _F_SIZE)

end

function HandView:getFocus()
  return self.focus_index
end

function HandView:moveFocus(dir)
  if dir == "left" then
    self.focus_index = math.max(1, self.focus_index - 1)
  elseif dir == "right" then
    self.focus_index = math.min(#self.hand, self.focus_index + 1)
  end
end

function HandView:getActionType()
  return _ACTION_TYPES[self.action_type]
end

function HandView:changeActionType(dir)
  if dir == 'up' then
    self.action_type = (self.action_type - 2)%3 + 1
  elseif dir == 'down' then
    self.action_type = self.action_type%3 + 1
  else
    error(("Unknown dir %s"):format(dir))
  end
end

function HandView:activate()
  self.focus_index = 1
  self.action_type = 1
  self:removeTimer("start", MAIN_TIMER)
  self:removeTimer("end", MAIN_TIMER)
  self:addTimer("start", MAIN_TIMER, "tween",
                                           0.2,
                                           self,
                                           { y = self.initial_y - CARD.getHeight() },
                                           'out-cubic')
end

function HandView:deactivate()
  self.focus_index = -1
  self.action_type = -1

  self:removeTimer("start", MAIN_TIMER)
  self:removeTimer("end", MAIN_TIMER)

  self:addTimer("end", MAIN_TIMER, "tween",
                                        0.2,
                                        self,
                                        {y = self.initial_y},
                                         'out-cubic')
end

function HandView:draw()
  local x, y = self.x, self.y
  local gap = CARD.getWidth() + 20
  local g = love.graphics
  _font.set()
  for i, card in ipairs(self.hand) do
    CARD.draw(card, x, y, i == self.focus_index)
    if i == self.focus_index then
      g.setColor(COLORS.NEUTRAL)
      g.print(self:getActionType(), x + 2, y - 1.5*_font:getHeight())
    end
    x = x + gap
  end
end

function HandView:addCard(actor, card)
  if self.route.getControlledActor() == actor then
    table.insert(self.hand, card)
  end
end

--Remove card given by index (must be valid)
function HandView:removeCard(actor, card_index)
  if self.route.getControlledActor() == actor then
    table.remove(self.hand, card_index)
  end
end

function HandView:reset()
  self.hand = {}

  local controlled_actor = self.route.getControlledActor()
  if controlled_actor then
    for i,card in ipairs(controlled_actor:getHand()) do
      self.hand[i] = card
    end
  end

end

return HandView
