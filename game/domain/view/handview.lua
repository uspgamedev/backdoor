--Local Functions--

local drawCard

--CardView properties

local card_view = {
  w = 130,
  h = 200,
}

--HandView Class--

local HandView = Class{
  __includes = { ELEMENT }
}

--Class Functions--

function HandView:init(hand)
  ELEMENT.init(self)

  self.hand = hand
  self.focus_index = -1 --What card is focused. -1 if none
  self.x, self.y = 100, O_WIN_H - card_view.h - 30
  self.initial_x, self.initial_y = self.x, self.y

end

function HandView:draw()

  local x, y = self.x, self.y
  local gap = 150
  for i, card in ipairs(self.hand) do
    drawCard(card, x, y, i == self.focus_index)
    x = x + gap
  end

end

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
