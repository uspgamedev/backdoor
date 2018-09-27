
local FONT        = require 'view.helpers.font'
local COLORS      = require 'domain.definitions.colors'
local VIEWDEFS    = require 'view.definitions'

local Transmission = require 'view.transmission'

local vec2        = require 'cpml' .vec2

local _MW = 16
local _SPD = 20
local _FLASH_TIME = 0.2

local Announcement = Class{
  __includes = { ELEMENT }
}

function Announcement:init()
  local w, h = love.graphics.getDimensions()
  ELEMENT.init(self)
  self.pos = vec2()
  self.size = vec2()
  self.text = nil
  self.font = FONT.get('Text', 32)
  self.flash = 0
  self.add = 0
  self.visible = false
  self.cooldown = 0
  self.closing = false
end

function Announcement:announce(text)
  assert(not self:isBusy())
  local w, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
  self.text = text
  self.size.x = self.font:getWidth(self.text) + 2*_MW
  self.size.y = self.font:getHeight()
  self.pos.x = w/2
  self.pos.y = 160
  self.visible = true
  self.flash = _FLASH_TIME
  self.add = 1.0
  self.cooldown = 3.0
  self.flashcolor = COLORS.FLASH_ANNOUNCE
  self.locked = false
end

function Announcement:getPoint()
  return self.pos + self.size/2
end

function Announcement:lock()
  self.locked = true
end

function Announcement:unlock()
  self.locked = false
end

function Announcement:isLocked()
  return self.locked
end

function Announcement:isBusy()
  return not not self.text
end

function Announcement:interrupt()
  self.cooldown = 0
end

function Announcement:close()
  if not self.text or self.closing then return end
  self.text = false
  self.visible = false
end

function Announcement:update(dt)
  if self.flash > 0 then
    self.flash = math.max(0, self.flash - dt)
  else
    if self.add > 0.05 then
      self.add = self.add - self.add * dt * _SPD
    else
      self.add = 0
    end
  end
  if self.cooldown > 0 then
    self.cooldown = self.cooldown - dt
  else
    self:close()
  end
end

function Announcement:draw()
  if not self.visible then return end
  local g = love.graphics
  local scale = 1 - self.flash/_FLASH_TIME
  local w, h = self.size.x*scale, self.size.y
  g.push()
  g.translate(self.pos:unpack())
  g.setColor(COLORS.HUD_BG)
  g.rectangle('fill', -w/2, -h/2, w, h)
  g.setColor(COLORS.NEUTRAL)
  g.setLineWidth(2)
  g.rectangle('line', -w/2+2, -h/2+2, w-4, h-4)
  self.font:set()
  if scale >= 1 then
    g.printf(self.text, -w/2 + _MW, -h/2, w - 2*_MW, 'center')
  end
  local cr, cg, cb = self.flashcolor:unpack()
  g.setColor(cr, cg, cb, self.add)
  g.rectangle('fill', -w/2, -h/2, w, h)
  g.pop()
end

return Announcement
