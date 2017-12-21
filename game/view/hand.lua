
local FONT = require 'view.helpers.font'
local CARD = require 'view.helpers.card'
local COLORS = require 'domain.definitions.colors'


--LOCAL FUNCTIONS DECLARATIONS--

local _drawCard

--CONSTS--
local _WIDTH, _HEIGHT
local _F_NAME = "Title" --Font name
local _F_SIZE = 24 --Font size
local _ACTION_TYPES = {
  'use', 'stash',
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
  _WIDTH, _HEIGHT = love.graphics.getDimensions()

end

function HandView:getFocus()
  return self.focus_index
end

function HandView:moveFocus(dir)
  if dir == "LEFT" then
    self.focus_index = (self.focus_index + #self.hand - 2) % #self.hand + 1
  elseif dir == "RIGHT" then
    self.focus_index = self.focus_index % #self.hand + 1
  end
end

function HandView:getActionType()
  return _ACTION_TYPES[self.action_type]
end

function HandView:changeActionType(dir)
  if dir == 'UP' then
    self.action_type = (self.action_type - 2) % #_ACTION_TYPES + 1
  elseif dir == 'DOWN' then
    self.action_type = self.action_type % #_ACTION_TYPES + 1
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
  local boxwidth = 128
  local g = love.graphics

  -- draw action type
  if not not self:getActionType() then
    _font.set()
    local colorname = self:getActionType():upper()
    local poly = {
      0, _HEIGHT/2,
      self.x + boxwidth, _HEIGHT/2,
      self.x + boxwidth, _HEIGHT/2 + 40,
      self.x + boxwidth - 20, _HEIGHT/2 + 60,
      0, _HEIGHT/2 + 60,
    }
    g.push()
    g.translate(2,2)
    g.setColor(COLORS.DARK)
    g.polygon("fill", poly)
    g.pop()
    g.setColor(COLORS[colorname])
    g.polygon("fill", poly)
    g.setColor(COLORS.NEUTRAL)
    g.printf(self:getActionType(), self.x, _HEIGHT/2+10, boxwidth, "left")
  end

  -- draw each card
  for i, card in ipairs(self.hand) do
    CARD.draw(card, x, y, i == self.focus_index)
    x = x + gap
    if self.focus_index == i then
      local infox = self.x + 5*gap + 20
      CARD.drawInfo(card, infox, self.y - 40, _WIDTH - infox - 40, 1)
    end
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
