--LOCAL FUNCTIONS DECLARATIONS--

local drawCard

--CARDVIEW PROPERTIES--

local card_view = {
  w = 130,
  h = 200,
}

--HandView Class--

local HandView = Class{
  __includes = { ELEMENT }
}

--CLASS FUNCTIONS--

function HandView:init(route)

  ELEMENT.init(self)

  self.focus_index = -1 --What card is focused. -1 if none
  self.x, self.y = 100, O_WIN_H - 30
  self.initial_x, self.initial_y = self.x, self.y
  self.route = route
  self:reset()

end

function HandView:draw()
  local x, y = self.x, self.y
  local gap = 150
  for i, card in ipairs(self.hand) do
    drawCard(card, x, y, i == self.focus_index)
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
function drawCard(card, x, y, focused)
  --Draw card background
  if focused then
    love.graphics.setColor(244, 164, 66)
  else
    love.graphics.setColor(66, 134, 244)
  end
  love.graphics.rectangle("fill", x, y, card_view.w, card_view.h)
  love.graphics.setColor(0,0,0)
  local old_line_w = love.graphics.getLineWidth()
  love.graphics.setLineWidth(3)
  love.graphics.rectangle("line", x, y, card_view.w, card_view.h)
  love.graphics.setLineWidth(old_line_w)

  --Draw card info
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(card:getName(), x + 5, y + 5)

end

return HandView
