
local RES = require 'resources'

--LOCAL FUNCTIONS DECLARATIONS--

local _drawCard

--CARDVIEW PROPERTIES--

local card_view = {
  w = 130,
  h = 200,
}

local _font = function () return RES.loadFont("Text", 24) end
local _ACTION_TYPES = {
  'use', 'remember', 'consume'
}

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
                                           { y = self.initial_y - 200 },
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
  local gap = 150
  local g = love.graphics
  g.setFont(_font())
  for i, card in ipairs(self.hand) do
    _drawCard(card, x, y, i == self.focus_index)
    if i == self.focus_index then
      g.print(self:getActionType(), x, y - 32)
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


  --LOCAL FUNCTIONS--

--Draw a card starting its upper left corner on given x,y values
function _drawCard(card, x, y, focused)
  local g = love.graphics
  --Draw card background
  if focused then
    g.setColor(244, 164, 66)
  else
    g.setColor(66, 134, 244)
  end
  g.rectangle("fill", x, y, card_view.w, card_view.h)
  g.setColor(0,0,0)
  local old_line_w = g.getLineWidth()
  g.setLineWidth(3)
  g.rectangle("line", x, y, card_view.w, card_view.h)
  g.setLineWidth(old_line_w)

  --Draw card info
  g.setColor(0, 0, 0)
  g.print(card:getName(), x + 5, y + 5)

end

return HandView
