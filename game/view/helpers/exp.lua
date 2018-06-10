
local FONT = require 'view.helpers.font'
local COLORS = require 'domain.definitions.colors'

local min = math.min
local delta = love.timer.getDelta


local _OFFSET_SPEED = 120

local _card
local _offset = 0
local _darkcolor = COLORS.DARK
local _positivecolor = COLORS.VALID
local _negativecolor = COLORS.WARNING

local function _drawEXP(g, exptext, color)
  local x, y = 3/4*g.getWidth()+120, g.getHeight()/2 + 2
  local dr, dg, db = _darkcolor:unpack()
  local red, green, blue = color:unpack()
  local alpha = (_offset+15)/15
  FONT.set("Text", 20)
  g.push()
  g.origin()
  g.translate(x, y)
  g.setColor(dr, dg, db, alpha)
  g.print(exptext, 0, _offset - 1)
  g.setColor(red, green, blue, alpha)
  g.print(exptext, 0, _offset - 3)
  g.pop()
end

local function _checkChangedCard(card)
  if card ~= _card then
    _card = card
    _offset = -10
  end
end

local function _updateOffset()
  if _offset < 0 then
    _offset = min(0, _offset + _OFFSET_SPEED*delta())
  end
end

local GAINED = {}

function GAINED.drawNeededEXP(g, card)
  local exp = card:isUpgrade() and card:getUpgradeCost()
  _checkChangedCard(card)
  if exp then
    local exptext = ("-%d"):format(exp)
    _drawEXP(g, exptext, _negativecolor)
    _updateOffset()
  end
end

return GAINED

