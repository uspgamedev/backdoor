--Local Functions--

local drawCard

--HandView Class--

local HandView = Class{
  __includes = { ELEMENT }
}

--Class Functions--

function HandView:init(hand)
  ELEMENT.init(self)

  self.hand = hand
  self.x, self.y = 100, 20

end

function HandView:draw()

  local x, y = self.x, self.y
  local gap = 30
  for i, card in ipairs(self.hand) do
    drawCard(card, x, y)
    x = x + gap
  end

end

--Draw a card starting its upper left corner on given x,y values
function drawCard(card, x, y)
  local width, height = 130, 200

  --Draw card background
  love.graphics.setColor(66, 134, 244)
  love.graphics.rectangle("fill", x, y, width, height)
  love.graphics.setColor(0,0,0)
  local old_line_w = love.graphics.getLineWidth()
  love.graphics.setLineWidth(3)
  love.graphics.rectangle("line", x, y, width, height)
  love.graphics.setLineWidth(old_line_w)

  --Draw card info
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(card:getName(), x + 5, y + 5)

end

return HandView
