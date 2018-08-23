
local TEXTURE = require 'view.helpers.texture'
local FONT    = require 'view.helpers.font'
local DEFS    = require 'view.definitions'
local COLORS  = require 'domain.definitions.colors'
local round   = require 'common.math' .round
local vec2    = require 'cpml' .vec2

local _title_font = FONT.get("TextBold", 20)
local _info_font = FONT.get("Text", 18)
local _card_font = FONT.get("Text", 12)

local CardView = Class{
  __includes = { ELEMENT }
}

local _ENTER_SPD = 5
local _FLASH_SPD = 20

local _DRAW = {}

function _DRAW:getRelatedAttr()
  return 'NONE'
end

function _DRAW:getType()
  return ''
end

function _DRAW:getName()
  return "New Hand"
end

function _DRAW:getEffect(player_actor)
  local pp
  if player_actor then
    pp = player_actor:getBody():getConsumption()
  end
  return ("Action [-%s PP]\n\nDiscard your hand, draw five cards."):format(pp)
end

function _DRAW:getDescription()
  return ""
end

function _DRAW:getIconTexture()
end

function _DRAW:isWidget()
end

function CardView:init(card)
  ELEMENT.init(self)
  self.sprite = TEXTURE.get('card-base')
  self.sprite:setFilter("linear", "linear", 1)
  self.card = card == 'draw' and _DRAW or card
  self.focused = false
  self.enter = false
  self.alpha = 0
  self.flash = false
  self.add = 0
end

function CardView:getWidth()
  return self.sprite:getWidth()
end

function CardView:getHeight()
  return self.sprite:getHeight()
end

function CardView:getDimensions()
  return self.sprite:getDimensions()
end

function CardView:setFocus(flag)
  self.focused = flag
end

function CardView:update(dt)
  if self.enter then
    if self.alpha < 0.95 then
      self.alpha = self.alpha + (1 - self.alpha) * dt * _ENTER_SPD
    else
      self.alpha = 1
    end
  else
    if self.alpha > 0.05 then
      self.alpha = self.alpha - self.alpha * dt * _ENTER_SPD
    else
      self.alpha = 0
    end
  end
  if self.flash then
    if self.add < 0.95 then
      self.add = self.add + (1 - self.add) * dt * _FLASH_SPD
    else
      self.add = 1
    end
  else
    if self.add > 0.05 then
      self.add = self.add - self.add * dt * _FLASH_SPD
    else
      self.add = 0
    end
  end
end

function CardView:draw(x, y)
  --Draw card background
  local g = love.graphics
  local cr, cg, cb = unpack(COLORS[self.card:getRelatedAttr()])
  local w, h = self.sprite:getDimensions()
  local typewidth = _info_font:getWidth(self.card:getType())
  local pd = 12
  g.push()

  if self.focused then
    -- shine!
    local shine = 50/255
    local cardname = self.card:getName()
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
  self.sprite:draw(x+2, y+2)

  --card
  g.setColor(cr, cg, cb, alpha)
  self.sprite:draw(x, y)

  --card icon
  local br, bg, bb = unpack(COLORS.DARK)
  local icon_texture = TEXTURE.get(self.card:getIconTexture() or 'icon-none')
  g.setColor(br, bg, bb, alpha)
  icon_texture:setFilter('linear', 'linear')
  icon_texture:draw(x+w/2, y+h/2, 0, 72/120, 72/120,
                    icon_texture:getWidth()/2,
                    icon_texture:getHeight()/2
  )
  g.push()
  g.translate(x, y)
  --Draw card info
  g.setColor(0x20/255, 0x20/255, 0x20/255, self.alpha)
  g.printf(self.card:getType(), w-pd-typewidth, 0, typewidth, "right")
  if self.card:isWidget() then
    g.printf(("[%d]"):format(
      self.card:getWidgetCharges() - self.card:getUsages()),
      pd, h - pd - _card_font:getHeight(), w-pd*2, "left"
    )
  end
  g.pop()

  if self.add > 0 then
    g.setBlendMode("add")
    g.setColor(1, 1, 1, self.add)
    self.sprite:draw(x, y)
    g.setBlendMode("alpha")
  end

  g.pop()
end

return CardView

