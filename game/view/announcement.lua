
local FONT        = require 'view.helpers.font'
local COLORS      = require 'domain.definitions.colors'
local VIEWDEFS    = require 'view.definitions'

local Transmission = require 'view.transmission'

local vec2        = require 'cpml' .vec2

local _MW = 16
local _SPD = 20

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
  self.hardadd = 0
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
  self.pos.x = w/2 - self.size.x/2
  self.pos.y = 160
  self.visible = true
  self.flash = 0.5
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
  self.hardadd = 0
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
  g.setColor(COLORS.HUD_BG)
  g.rectangle('fill', self.pos.x, self.pos.y, self.size.x, self.size.y)
  g.setColor(COLORS.NEUTRAL)
  g.setLineWidth(2)
  g.rectangle('line', self.pos.x+2, self.pos.y+2, self.size.x-4, self.size.y-4)
  self.font:set()
  g.printf(self.text, self.pos.x + _MW, self.pos.y, self.size.x - 2*_MW,
           'center')
  local cr, cg, cb = self.flashcolor:unpack()
  g.setColor(cr, cg, cb, self.add + self.hardadd)
  g.rectangle('fill', self.pos.x, self.pos.y, self.size.x, self.size.y)
end

return Announcement
