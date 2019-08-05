
-- luacheck: globals love

local TEXTURE     = require 'view.helpers.texture'
local FONT        = require 'view.helpers.font'
local COLORS      = require 'domain.definitions.colors'
local Color       = require 'common.color'
local round       = require 'common.math' .round
local vec2        = require 'cpml' .vec2
local Class       = require "steaming.extra_libs.hump.class"
local ELEMENT     = require "steaming.classes.primitives.element"
local TweenValue  = require 'view.helpers.tweenvalue'

local _title_font = FONT.get("TextBold", 20)
local _info_font = FONT.get("Text", 18)
local _card_font = FONT.get("Text", 12)

local CardView = Class{
  __includes = { ELEMENT }
}

local _FLASH_SPD = 20

function CardView:init(card)
  ELEMENT.init(self)
  self.sprite = TEXTURE.get('card-base')
  self.sprite:setFilter("linear", "linear", 1)
  self.card = card
  self.scale = 1
  self.focused = false
  self.alpha = 1
  self.flash = 0
  self.add = 0
  self.flashcolor = nil
  self.position = vec2()
  self.raised = TweenValue(0, 'smooth', 5)
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

function CardView:setAlpha(alpha)
  self.alpha = alpha
end

function CardView:setScale(scale)
  self.scale = scale
end

function CardView:flashFor(duration, color)
  self.flash = duration
  self.flashcolor = color or COLORS.NEUTRAL
end

function CardView:raise()
  return self.raised:set(200)
end

function CardView:update(dt)
  if self.flash > 0 then
    self.flash = math.max(0, self.flash - dt)
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

function CardView:setPosition(x, y)
  self.position = vec2(x,y)
end

function CardView:getPosition()
  return self.position:unpack()
end

function CardView:getPoint()
  return self.position + vec2(self:getDimensions())/2
                       - vec2(0,self.raised:get())
end

function CardView:draw()
  --Draw card background
  local x,y = self.position:unpack()
  y = y - self.raised:get()
  local g = love.graphics
  local cr, cg, cb = unpack(COLORS[self.card:getRelatedAttr()])
  local w, h = self.sprite:getDimensions()
  local typewidth = _info_font:getWidth(self.card:getType())
  local pd = 12
  g.push()
  g.scale(self.scale, self.scale)

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
    g.setColor(COLORS.NEUTRAL * Color:new{1,1,1,self.alpha})
    g.printf(cardname, x + round((w - namewidth)/2),
             round(y-pd-_title_font:getHeight()),
             namewidth, "center")
  end

  _card_font.set()

  --shadow
  g.setColor(0, 0, 0, self.alpha)
  self.sprite:draw(x+2, y+2)

  --card
  g.setColor(cr, cg, cb, self.alpha)
  self.sprite:draw(x, y)

  --card icon
  local br, bg, bb = unpack(COLORS.DARK)
  local icon_texture = TEXTURE.get(self.card:getIconTexture() or 'icon-none')
  g.setColor(br, bg, bb, self.alpha)
  icon_texture:setFilter('linear', 'linear')
  icon_texture:draw(x+w/2, y+h/2, 0, 72/120, 72/120,
                    icon_texture:getWidth()/2,
                    icon_texture:getHeight()/2
  )
  g.push()
  g.translate(x, y)
  --Draw card info
  g.setColor(0x20/255, 0x20/255, 0x20/255, self.alpha)
  g.printf(self.card:getType(), pd, h - pd - _card_font:getHeight(), typewidth,
           "left")
  _info_font.set()
  if self.card:isArt() then
    g.printf(("(%d)"):format(self.card:getArtCost()),
             pd, 0, w-pd*2, "right")
  elseif self.card:isWidget() then
    g.printf(("[%d]"):format(self.card:getWidgetCharges()
                           - self.card:getUsages()),
             pd, 0, w-pd*2, "right")
  end
  g.pop()

  if self.add > 0 then
    g.setColor(self.flashcolor[1], self.flashcolor[2], self.flashcolor[3],
               self.add)
    self.sprite:draw(x, y)
  end

  g.pop()
end

return CardView

