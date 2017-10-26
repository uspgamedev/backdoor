
local FONT = require 'view.helpers.font'
local COLORS = require 'domain.definitions.colors'

--CARDVIEW PROPERTIES--

local _title_font = FONT.get("TextBold", 21)
local _text_font = FONT.get("Text", 21)

local _CARD_VIEW = {
  w = 90,
  h = 150,
}

local CARD = {}

--Draw a card starting its upper left corner on given x,y values
--Alpha is a float value between [0,1] applied to all graphics
function CARD.draw(card, x, y, focused, alpha)
  alpha = alpha or 1
  --Draw card background
  local g = love.graphics
  local cr, cg, cb = unpack(COLORS[card:getRelatedAttr()])
  g.push()

  g.translate(x, y)

  if focused then
    g.scale(1.1)
    g.translate(-0.05*_CARD_VIEW.w, -0.05*_CARD_VIEW.h)
    cr, cg, cb = cr+80, cg+80, cb+80
  end
  --shadow
  g.setColor(0, 0, 0, alpha*0x80)
  g.rectangle("fill", 4, 4, _CARD_VIEW.w, _CARD_VIEW.h)

  --card
  g.setColor(cr, cg, cb, alpha*255)
  g.rectangle("fill", 0, 0, _CARD_VIEW.w, _CARD_VIEW.h)

  --Draw card info
  local pd = 8
  g.setColor(0x20, 0x20, 0x20, alpha*255)
  _text_font.set()
  g.printf(card:getName(), pd, pd, _CARD_VIEW.w-pd, "left")

  g.pop()
end

--Draw the description of a card.
function CARD.drawInfo(card, x, y, width, alpha)
  alpha = alpha or 1
  local g = love.graphics
  local cr, cg, cb = unpack(COLORS.NEUTRAL)

  g.push()

  g.translate(x, y)
  g.setColor(cr, cg, cb, alpha*255)

  _title_font:setLineHeight(1.5)
  _title_font.set()
  g.printf(card:getName(), 0, 0, width)

  g.translate(_title_font:getHeight())

  _text_font.set()
  g.printf(card:getDescription(), 0, 0, width)

  g.pop()
end

function CARD.getWidth()
  return _CARD_VIEW.w
end

function CARD.getHeight()
  return _CARD_VIEW.h
end


return CARD
