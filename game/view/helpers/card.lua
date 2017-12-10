
local FONT = require 'view.helpers.font'
local TEXTURE = require 'view.helpers.texture'
local RES = require 'resources'
local COLORS = require 'domain.definitions.colors'

--CARDVIEW PROPERTIES--

local _title_font = FONT.get("TextBold", 21)
local _text_font = FONT.get("Text", 21)
local _info_font = FONT.get("Text", 18)
local _card_base
local _neutral_icon

local CARD = {}

local _is_init = false
local function _init()
  _card_base = TEXTURE.get("card-base")
  _card_base:setFilter("linear", "linear", 1)

  _is_init = true
end


--Draw a card starting its upper left corner on given x,y values
--Alpha is a float value between [0,1] applied to all graphics
function CARD.draw(card, x, y, focused, alpha)
  if not _is_init then _init() end
  alpha = alpha or 1
  --Draw card background
  local g = love.graphics
  local cr, cg, cb = unpack(COLORS[card:getRelatedAttr()])
  local w, h = _card_base:getDimensions()
  local typewidth = _info_font:getWidth(card:getType())
  local pd = 12
  g.push()


  if focused then
    -- shine!
    local shine = 50
    g.translate(0, -10)
    cr = cr + shine
    cg = cg + shine
    cb = cb + shine
    _title_font:set()
    g.setColor(COLORS.NEUTRAL)
    g.printf(card:getName(), x+pd, y-pd-_title_font:getHeight(), w-pd*2, "center")
  end

  _info_font.set()

  --shadow
  g.setColor(0, 0, 0, alpha*255)
  _card_base:draw(x+2, y+2)

  --card
  g.setColor(cr, cg, cb, alpha*255)
  _card_base:draw(x, y)

  --card icon
  local br, bg, bb = unpack(COLORS.DARK)
  local icon_texture = TEXTURE.get(card:getIconTexture() or 'icon-none')
  g.setColor(br, bg, bb, alpha*255)
  icon_texture:setFilter('linear', 'linear')
  icon_texture:draw(x+w/2, y+h/2, 0, 1, 1,
                    icon_texture:getWidth()/2,
                    icon_texture:getHeight()/2
  )

  g.translate(x, y)
  --Draw card info
  g.setColor(0x20, 0x20, 0x20, alpha*255)
  g.printf(card:getType(), w-pd-typewidth, 0, typewidth, "right")

  if card:isWidget() then
    g.printf(("[%d]"):format(card:getWidgetCharges()-card:getUsages()),
             pd, h-pd-_info_font:getHeight(), w-pd*2, "left"
    )
  end

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

  g.translate(0, _title_font:getHeight())

  _text_font.set()
  local desc = card:getDescription():gsub("([^\n])[\n]([^\n])", "%1 %2")
  g.printf(desc:gsub("\n\n", "\n") or "[No description]", 0, 0, width)

  g.pop()
end

function CARD.getWidth()
  if not _is_init then _init() end
  return _card_base:getWidth()
end

function CARD.getHeight()
  if not _is_init then _init() end
  return _card_base:getHeight()
end


return CARD
