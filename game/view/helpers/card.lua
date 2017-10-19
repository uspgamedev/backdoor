local FONT = require 'view.helpers.font'
local COLORS = require 'domain.definitions.colors'

--CARDVIEW PROPERTIES--

local card_view = {
  w = 90,
  h = 150,
}

local CARD = {}

--Draw a card starting its upper left corner on given x,y values
function CARD.draw(card, x, y, focused)
  --Draw card background
  local g = love.graphics
  local cr, cg, cb = unpack(COLORS[card:getRelatedAttr()])
  g.push()

  g.translate(x, y)

  if focused then
    g.scale(1.1)
    g.translate(-0.05*card_view.w, -0.05*card_view.h)
    cr, cg, cb = cr+80, cg+80, cb+80
  end
  --shadow
  g.setColor(0, 0, 0, 0x80)
  g.rectangle("fill", 4, 4, card_view.w, card_view.h)

  --card
  g.setColor(cr, cg, cb)
  g.rectangle("fill", 0, 0, card_view.w, card_view.h)

  --Draw card info
  local pd = 8
  g.setColor(0x20, 0x20, 0x20)
  FONT.set("Text", 21)
  g.printf(card:getName(), pd, pd, card_view.w-pd, "left")

  g.pop()
end

function CARD.getWidth()
  return card_view.w
end

function CARD.getHeight()
  return card_view.h
end


return CARD
