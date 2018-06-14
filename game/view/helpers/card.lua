
local FONT = require 'view.helpers.font'
local TEXTURE = require 'view.helpers.texture'
local RES = require 'resources'
local COLORS = require 'domain.definitions.colors'
local round = require 'common.math' .round

--CARDVIEW PROPERTIES--

local _title_font = FONT.get("TextBold", 20)
local _text_font = FONT.get("Text", 20)
local _info_font = FONT.get("Text", 18)
local _card_font = FONT.get("Text", 12)
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
function CARD.draw(card, x, y, focused, alpha, scale)
  if not _is_init then _init() end
  alpha = alpha or 1
  scale = scale or 1
  --Draw card background
  local g = love.graphics
  local cr, cg, cb = unpack(COLORS[card:getRelatedAttr()])
  local w, h = _card_base:getDimensions()
  local typewidth = _info_font:getWidth(card:getType())
  local pd = 12
  g.push()
  g.scale(scale, scale)

  if focused then
    -- shine!
    local shine = 50/255
    local cardname = card:getName()
    local namewidth = _title_font:getWidth(cardname)
    g.translate(0, -10)
    cr = cr + shine
    cg = cg + shine
    cb = cb + shine
    _title_font:set()
    g.setColor(COLORS.NEUTRAL)
    g.printf(cardname, x + round((w - namewidth)/2),
             round(y-pd-_title_font:getHeight()),
             namewidth, "center")
  end

  _card_font.set()

  --shadow
  g.setColor(0, 0, 0, alpha)
  _card_base:draw(x+2, y+2)

  --card
  g.setColor(cr, cg, cb, alpha)
  _card_base:draw(x, y)

  --card icon
  local br, bg, bb = unpack(COLORS.DARK)
  local icon_texture = TEXTURE.get(card:getIconTexture() or 'icon-none')
  g.setColor(br, bg, bb, alpha)
  icon_texture:setFilter('linear', 'linear')
  icon_texture:draw(x+w/2, y+h/2, 0, 0.5, 0.5,
                    icon_texture:getWidth()/2,
                    icon_texture:getHeight()/2
  )

  g.translate(x, y)
  --Draw card info
  g.setColor(0x20/255, 0x20/255, 0x20/255, alpha)
  g.printf(card:getType(), w-pd-typewidth, 0, typewidth, "right")

  if card:isWidget() then
    g.printf(("[%d]"):format(card:getWidgetCharges()-card:getUsages()),
             pd, h-pd-_card_font:getHeight(), w-pd*2, "left"
    )
  end
  if card:isUpgrade() then
    g.printf(("+%d"):format(card:getUpgradeCost()),
             pd, h-pd-1.25*_card_font:getHeight(), w-pd*2, "left"
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
  g.setColor(cr, cg, cb, alpha)

  _title_font:setLineHeight(1.5)
  _title_font.set()
  g.printf(card:getName(), 0, 0, width)

  g.translate(0, _title_font:getHeight())

  _text_font.set()
  local desc = card:getDescription() or "[No description]"
  desc = desc:gsub("([^\n])[\n]([^\n])", "%1 %2")
  desc = desc:gsub("\n\n", "\n")
  g.printf(desc, 0, 0, width)

  g.pop()
end

function CARD.getInfoHeight(lines)
  _title_font:setLineHeight(1.5)
  return _text_font:getHeight() * _text_font:getLineHeight() * lines
end

function CARD.getInfoWidth(card, width)
  return _text_font:getWrap(card:getDescription(), width)
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
