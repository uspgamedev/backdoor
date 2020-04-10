
-- luacheck: globals love

local FONT        = require 'view.helpers.font'
local COLORS      = require 'domain.definitions.colors'
local VIEWDEFS    = require 'view.definitions'

local Activity    = require 'common.activity'
local Deferred    = require 'common.deferred'
local TweenValue  = require 'view.helpers.tweenvalue'
local Class       = require "steaming.extra_libs.hump.class"
local ELEMENT     = require "steaming.classes.primitives.element"

local vec2        = require 'cpml' .vec2

local _MW = 16
local _FLASH_TIME = 0.2

local _activity = Activity()

local Announcement = Class{
  __includes = { ELEMENT }
}

function Announcement:init()
  ELEMENT.init(self)
  self.pos = vec2()
  self.size = vec2()
  self.text = nil
  self.font = FONT.get('Text', 32)
  self.flash = TweenValue(0, 'linear')
  self.add = TweenValue(0, 'smooth', 20)
  self.cooldown = TweenValue(0, 'linear')
  self.invisible = true
  self.flashcolor = COLORS.FLASH_ANNOUNCE
  self.deferred = {}
end

function _activity:announce(ann)
  ann.add:snap(1)
  ann.flash:snap(0)
  self.wait(ann.flash:set(_FLASH_TIME))

  self.wait(ann.add:set(0))

  ann.cooldown:snap(2)
  self.wait(ann.cooldown:set(0))

  ann.add:set(1)
  self.wait(ann.flash:set(0))

  ann.text = false
  ann.invisible = true
  while #ann.deferred > 0 do
    local deferred = table.remove(ann.deferred)
    deferred:trigger()
    if ann:isBusy() then return end
  end
end

function Announcement:announce(text)
  assert(not self:isBusy())
  local w, _ = VIEWDEFS.VIEWPORT_DIMENSIONS()
  self.text = text
  self.size.x = self.font:getWidth(self.text) + 2*_MW
  self.size.y = self.font:getHeight()
  self.pos.x = w/2
  self.pos.y = 160
  self.invisible = false
  self.locked = false
  return _activity:announce(self)
end

function Announcement:interrupt()
  if self:isBusy() then
    self.cooldown:snap(0)
    local deferred = Deferred:new()
    table.insert(self.deferred, deferred)
    return deferred
  end
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

function Announcement:draw()
  local g = love.graphics
  local scale = self.flash:get()/_FLASH_TIME
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
  g.setColor(cr, cg, cb, self.add:get())
  g.rectangle('fill', -w/2, -h/2, w, h)
  g.pop()
end

return Announcement
