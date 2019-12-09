
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
local RES         = require 'resources'

local _title_font = FONT.get("TextBold", 20)
local _info_font = FONT.get("Text", 18)
local _card_font = FONT.get("Text", 12)
local _widget_charge_font = FONT.get("TextBold", 14)
local _focus_speed = 5
local _icon_offset_speed = 80
local _info_alpha_speed = 5
local _mode_scale_speed = 3
local _charge_offset_speed = 200
local _widget_charge_pos = vec2(7, 4)
local _widget_charge_radius = 13
local _widget_charge_linew = 3

--Local functions

local _draw_hexagon

local _MODE = {
    normal = "normal",
    cond =  "condition",
    equip = "equipment"
}

local CardView = Class{
  __includes = { ELEMENT }
}

local _FLASH_SPD = 20

function CardView:init(card)
  ELEMENT.init(self)
  self.temporary = card:isTemporary()
  self.sprite = self.temporary and TEXTURE.get('temporary-card-base') or
                                   TEXTURE.get('card-base')
  self.sprite:setFilter("nearest", "nearest", 1)
  self.card = card
  self.scale = 1
  self.focused = false
  self.focus_value = 0
  self.alpha = 1
  self.stencil = function() end
  self.flash = 0
  self.add = 0
  self.flashcolor = nil
  self.position = vec2()
  self.offset = vec2()
  self.raised = TweenValue(0, 'smooth', 5)

  --Attributes related to different modes
  self.mode = _MODE.normal
  self.icon_offset = vec2(0,0)
  self.info_alpha = 1
  self.mode_scale = vec2(1,1)
  self.charge_offset = vec2(0,0)
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

function CardView:setMode(mode)
  assert(_MODE[mode], "Not a valid mode for cardview")
  self.mode = _MODE[mode]
end

function CardView:setAlpha(alpha)
  self.alpha = alpha
end

function CardView:setStencil(func)
  self.stencil = func
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
  if self.focused then
    self.focus_value = math.min(1, self.focus_value + _focus_speed*dt)
  else
    self.focus_value = math.max(0, self.focus_value - _focus_speed*dt)
  end
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

  --Switch between modes
  if self.mode == _MODE.normal then
    self.icon_offset.x = math.min(self.icon_offset.x + _icon_offset_speed*dt, 0)
    self.icon_offset.y = math.min(self.icon_offset.y + _icon_offset_speed*dt, 0)
    self.info_alpha = math.min(self.info_alpha + _info_alpha_speed*dt, 1)
    self.mode_scale.x = math.min(self.mode_scale.x + _mode_scale_speed*dt, 1)
    self.mode_scale.y = math.min(self.mode_scale.y + _mode_scale_speed*dt, 1)
    self.charge_offset.x = math.max(self.charge_offset.x - _charge_offset_speed*dt, 0)
    self.charge_offset.y = math.max(self.charge_offset.y - _charge_offset_speed*dt, 0)
  elseif self.mode == _MODE.equip then
    self.icon_offset.x = math.min(self.icon_offset.x + _icon_offset_speed*dt, 0)
    self.icon_offset.y = math.max(self.icon_offset.y - _icon_offset_speed*dt, -30)
    self.info_alpha = math.max(self.info_alpha - _info_alpha_speed*dt, 0)
    self.mode_scale.x = math.min(self.mode_scale.x + _mode_scale_speed*dt, 1)
    self.mode_scale.y = math.min(self.mode_scale.y + _mode_scale_speed*dt, 1)
    self.charge_offset.x = math.min(self.charge_offset.x + _charge_offset_speed*dt, 56)
    self.charge_offset.y = math.max(self.charge_offset.y - _charge_offset_speed*dt, 0)
  elseif self.mode == _MODE.cond then
    self.icon_offset.x = math.max(self.icon_offset.x - _icon_offset_speed*dt, -5)
    self.icon_offset.y = math.max(self.icon_offset.y - _icon_offset_speed*dt, -23)
    self.info_alpha = math.max(self.info_alpha - _info_alpha_speed*dt, 0)
    self.mode_scale.x = math.max(self.mode_scale.x - _mode_scale_speed*dt, .64)
    self.mode_scale.y = math.max(self.mode_scale.y - _mode_scale_speed*dt, .40)
    self.charge_offset.x = math.min(self.charge_offset.x + _charge_offset_speed*dt, 10)
    self.charge_offset.y = math.min(self.charge_offset.y + _charge_offset_speed*dt, 10)
  else
    error("Not a valid mode for cardview")
  end
end

function CardView:setPosition(x, y)
  self.position = vec2(x,y)
end

function CardView:getPosition()
  return self.position:unpack()
end

function CardView:setOffset(x, y)
  self.offset = vec2(x,y)
end

function CardView:getOffset()
  return self.offset:unpack()
end

function CardView:getPoint()
  return self.position + self.offset + vec2(self:getDimensions())/2
                       - vec2(0,self.raised:get())
end

function CardView:draw()
  --Draw card background
  local x,y = self.position:unpack()
  y = y - self.raised:get()
  local g = love.graphics
  local cr, cg, cb = unpack(COLORS[self.card:getRelatedAttr()])
  local w, h = self.sprite:getDimensions()
  local typewidth = _card_font:getWidth(self.card:getType() .. " [ xx ]")
  local pd = 12
  g.push()
  g.stencil(self.stencil, "replace", 1)
  g.setStencilTest("equal", 0)
  g.translate(self:getOffset())
  g.scale(self.scale, self.scale)
  g.translate(0, -40*self.focus_value)

  if self.focused then
    _title_font:set()
    local cardname = self.card:getName()
    local namewidth = _title_font:getWidth(cardname)
    g.setColor(COLORS.NEUTRAL * Color:new{1,1,1,self.alpha})
    g.printf(cardname, x + round((w - namewidth)/2),
             round(y-pd-_title_font:getHeight()),
             namewidth, "center")
  end

  _card_font.set()

  --shadow
  g.setColor(0, 0, 0, self.alpha)
  self.sprite:draw(x+2, y+2, 0, self.mode_scale.x, self.mode_scale.y,
                   (self.mode_scale.x-1)*self.sprite:getWidth()/2,
                   (self.mode_scale.y-1)*self.sprite:getHeight()/2)

  --card
  local shine = 50/255
  cr = cr + shine
  cg = cg + shine
  cb = cb + shine
  g.setColor(cr, cg, cb, self.alpha)
  self.sprite:draw(x, y, 0, self.mode_scale.x, self.mode_scale.y,
                   (self.mode_scale.x-1)*self.sprite:getWidth()/2,
                   (self.mode_scale.y-1)*self.sprite:getHeight()/2)

  --card icon
  local br, bg, bb = unpack(COLORS.DARK)
  local icon_texture = TEXTURE.get(self.card:getIconTexture() or 'icon-none')
  local tw, th = icon_texture:getDimensions()
  g.setColor(br, bg, bb, self.alpha)
  g.push()
  g.translate(self.icon_offset.x, self.icon_offset.y)
  icon_texture:setFilter('linear', 'linear')
  icon_texture:draw(x+w/2, y+h/2, 0, self.mode_scale.x*64/tw,
                    self.mode_scale.x*64/th, tw/2, th/2)
  g.pop()
  g.push()
  g.translate(x, y)
  --Draw card info
  g.setColor(0x20/255, 0x20/255, 0x20/255, self.alpha*self.info_alpha)
  local type_str = self.card:getType()
  g.printf(type_str, pd, h - pd - _card_font:getHeight()/2, typewidth,
           "left")
  _info_font.set()
  local focus_icon = RES.loadTexture('focus-icon')
  local iw, ih = focus_icon:getDimensions()
  for i = 1, self.card:getCost() do
    g.setColor(br, bg, bb, self.alpha * self.info_alpha)
    g.push()
    g.translate(w - pd - (i - 1) * (pd - 2), pd)
    g.draw(focus_icon, 0, 0, 0, 1, 1, iw/2, ih/2)
    g.pop()
  end

  --Draw charge counter for widgets
  if self.card:isWidget() then
    local x = _widget_charge_pos.x + self.charge_offset.x
    local y = _widget_charge_pos.y + self.charge_offset.y
    local font = _widget_charge_font
    --Print background
    g.setColor(0, 0, 0, self.alpha)
    _draw_hexagon("fill", x, y, _widget_charge_radius)
    g.setColor(cr, cg, cb, self.alpha)
    g.setLineWidth(_widget_charge_linew)
    _draw_hexagon("line", x, y, _widget_charge_radius)

    --Print charges
    font.set()
    g.setColor(cr, cg, cb, self.alpha)
    local charges = self.card:getCurrentWidgetCharges()
    g.print(charges, x - font:getWidth(charges)/2,
                     y - font:getHeight()/2)
  end

  g.pop()

  if self.add > 0 then
    g.setColor(self.flashcolor[1], self.flashcolor[2], self.flashcolor[3],
               self.add)
    self.sprite:draw(x, y, 0, self.mode_scale.x, self.mode_scale.y,
                     (self.mode_scale.x-1)*self.sprite:getWidth()/2,
                     (self.mode_scale.y-1)*self.sprite:getHeight()/2)
    if self.card:isWidget() then
      g.circle("fill", x + _widget_charge_pos.x + self.charge_offset.x,
                y + _widget_charge_pos.y + self.charge_offset.y, _widget_charge_radius)
    end
  end
  g.setStencilTest()
  g.pop()
end

--Local functions

function _draw_hexagon(mode, x, y, r)
  local v = vec2(r, 0)
  local points = {}
  for i = 1, 6 do
    table.insert(points,x + v.x)
    table.insert(points,y + v.y)
    v = vec2.rotate(v, math.pi/3)
  end
  love.graphics.polygon(mode, points)
end

return CardView
