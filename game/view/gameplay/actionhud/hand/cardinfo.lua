
-- luacheck: globals love

local Color     = require 'common.color'
local TEXTURE   = require 'view.helpers.texture'
local COLORS    = require 'domain.definitions.colors'
local FONT      = require 'view.helpers.font'
local vec2      = require 'cpml' .vec2
local Class     = require "steaming.extra_libs.hump.class"
local ELEMENT   = require "steaming.classes.primitives.element"
local VIEWDEFS  = require 'view.definitions'
local RES       = require 'resources'

local _SCALE = 4
local _WIDTH = VIEWDEFS.CARD_W * _SCALE
local _HEIGHT = VIEWDEFS.CARD_H * _SCALE
local _MW = 16
local _MH = 12
local _PW = 16
local _PH = 12
local _CORNER = 12 * _SCALE

local CardInfo = Class{
  __includes = { ELEMENT }
}

function CardInfo:init(route)

  ELEMENT.init(self)

  local w, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
  self.route = route
  self.card = nil
  self.position = vec2(w * 0.02, h * 0.07)
  self.hide_desc = true
  self.title_font = FONT.get("TextBold", 24)
  self.text_font = FONT.get("Text", 18)
  self.alpha = 1
  self.invisible = true
  self.side = 'right'
  self.locked_card = nil

  --Oscilating effect
  self.oscilate = 0
  self.oscilate_magnitude = 4
  self.oscilate_speed = 4

end

function CardInfo:setCard(card)
  self.card = self.locked_card or card
end

function CardInfo:show()
  self.invisible = false
  self.alpha = 0
end

function CardInfo:hide()
  if not self.locked_card then
    self.invisible = true
  end
end

function CardInfo:lockCard(card)
  self.locked_card = card
  self.invisible = not card
end

function CardInfo:isVisible()
  return not self.invisible
end

function CardInfo:update(dt)
  if not self.invisible then
    self.oscilate = self.oscilate + self.oscilate_speed * dt
    self.alpha = self.alpha + (1 - self.alpha) * dt * 20
  end
end

function CardInfo:draw()
  local alpha = self.alpha
  local g = love.graphics
  local cr, cg, cb = unpack(COLORS.BLACK)
  local player_actor = self.route.getPlayerActor()

  local desc = self.card:getEffect(player_actor)
  if not self.hide_desc then
    desc = desc .. "\n\n---"
    desc = desc .. '\n\n' .. (self.card:getDescription() or "[No description]")
  end
  desc = desc:gsub("([^\n])[\n]([^\n])", "%1 %2")
  desc = desc:gsub("\n\n", "\n")

  self.text_font:setLineHeight(1)

  g.push()
  g.translate(self.position:unpack())
  local offset = math.sin(self.oscilate)*self.oscilate_magnitude
  g.translate(0, math.floor(offset+.5))

  local boxw = _WIDTH
  local boxh = _HEIGHT
  local corner = 12 * _SCALE
  local box = {
    0, corner,
    corner, 0,
    boxw, 0,
    boxw, boxh - corner,
    boxw - corner, boxh,
    0, boxh
  }

  -- Draw card-shaped panel
  g.push()
  local shadow = 8
  local attr_color = COLORS[self.card:getRelatedAttr()]
  g.translate(shadow, 2*shadow - offset)
  g.setColor(attr_color * Color:new{.4, .4, .4, alpha/2})
  g.polygon('fill', box)
  g.translate(-shadow, -(2*shadow - offset))
  g.setColor(attr_color * Color:new{1, 1, 1, alpha})
  g.polygon('fill', box)
  g.pop()

  self:drawFocusCost()

  g.translate(_MW, _MH*4)
  self:drawIcon()

  -- Draw description
  g.push()
  g.translate(0, _HEIGHT / 2)

  g.setColor(cr, cg, cb, alpha)

  self.title_font:setLineHeight(1.5)
  self.title_font.set()
  g.printf(self.card:getName(), 0, 0, _WIDTH - _MW*2, 'center')

  g.translate(0, 1.0 * self.title_font:getHeight())

  self.text_font.set()
  g.printf(desc, 0, 0, _WIDTH - _MW*2)

  g.pop()

  if self.card:isHalfExhaustion() then
    g.push()
    local c = COLORS.HALF_EXHAUSTION
    g.setColor(c[1], c[2], c[3], alpha)
    local quick_icon = RES.loadTexture("quick-card-icon")
    local scale = 2
    g.translate(0, 390)
    g.draw(quick_icon, 0, 0, 0, scale, scale)
    g.pop()
  end

  g.pop()
end

function CardInfo:drawFocusCost()
  local g = love.graphics
  local focus_icon = RES.loadTexture('focus-icon')
  local iw, _ = focus_icon:getDimensions()
  local pd = 4 + iw
  for i = 1, self.card:getCost() do
    g.setColor(COLORS.DARK * Color:new{1,1,1, self.alpha})
    g.push()
    g.translate(_WIDTH - _MW - (i - 1) * pd * 2, _MH)
    g.scale(2, 2)
    g.draw(focus_icon, 0, 0, 0, 1, 1, iw, 0)
    g.pop()
  end
end

function CardInfo:drawIcon()
  local g = love.graphics
  local inner_corner = _CORNER
  local left, right = 0, _WIDTH - (_MW+_PW)*2
  local top, bottom = 0, (_HEIGHT - (_MH+_PH)*2) / 2
  local icon_texture = TEXTURE.get(self.card:getIconTexture() or 'icon-none')
  local attr_color = COLORS[self.card:getRelatedAttr()]
  g.push()
  g.translate(_PW, _PH)
  g.setColor(COLORS.DARK)
  g.polygon('fill', left, top + inner_corner,
                    left + inner_corner, top,
                    right - inner_corner, top,
                    right, top + inner_corner,
                    right, bottom - inner_corner,
                    right - inner_corner, bottom,
                    left + inner_corner, bottom,
                    left, bottom - inner_corner)
  g.setColor(attr_color * Color:new{1, 1, 1, self.alpha})
  icon_texture:setFilter('linear', 'linear')
  icon_texture:draw((left+right)/2, (top+bottom)/2, 0, 1.5, 1.5,
                    icon_texture:getWidth()/2,
                    icon_texture:getHeight()/2)
  g.pop()
end

return CardInfo
