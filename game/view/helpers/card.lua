
local FONT = require 'view.helpers.font'
local TEXTURE = require 'view.helpers.texture'
local COLORS = require 'domain.definitions.colors'

--CARDVIEW PROPERTIES--

local _title_font = FONT.get("TextBold", 20)
local _text_font = FONT.get("Text", 20)
local _card_base

local CARD = {}

local _is_init = false
local function _init()
  _card_base = TEXTURE.get("card-base")
  _card_base:setFilter("linear", "linear", 1)

  _is_init = true
end

--Draw the description of a card.
function CARD.drawInfo(card, x, y, width, alpha, player_actor, no_desc)
  alpha = alpha or 1
  local g = love.graphics -- luacheck: globals love
  local cr, cg, cb = unpack(COLORS.NEUTRAL)
  if not (card:getOwner() and card:getOwner():canPlayCard(card)) then
    cr, cg, cb = unpack(COLORS.INVALID)
  end

  g.push()

  g.translate(x, y)
  g.setColor(cr, cg, cb, alpha)

  _title_font:setLineHeight(1.5)
  _title_font.set()
  g.printf(card:getName(), 0, 0, width)

  g.translate(0, _title_font:getHeight())

  _text_font.set()
  local desc = card:getEffect(player_actor)
  if not no_desc then
    desc = desc .. "\n\n---"
    desc = desc .. '\n\n' .. (card:getDescription() or "[No description]")
  end
  desc = desc:gsub("([^\n])[\n]([^\n])", "%1 %2")
  desc = desc:gsub("\n\n", "\n")
  g.printf(desc, 0, 0, width)

  g.pop()
end

function CARD.getInfoHeight(lines)
  return _text_font:getHeight() * _text_font:getLineHeight() * lines
end

function CARD.getInfoLines(card, maxwidth)
  local desc = card:getEffect()
  desc = desc:gsub("([^\n])[\n]([^\n])", "%1 %2")
  desc = desc:gsub("\n\n", "\n")
  local _, lines = _text_font:getWrap(desc, maxwidth)
  return #lines + 1 --One extra for the title
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
