
local INPUT = require 'input'
local DIRECTIONALS = require 'infra.dir'
local COLORS = require 'domain.definitions.colors'

local _TOTAL = 1
local _TIME = .8
local _ENTER_SPEED = 8
local _EPSILON = 0.01 -- 1%
local _WIDTH = 64
local _HEIGHT = 16

local _dt = love.timer.getDelta

local function _tween(from, to, smooth)
  local step = (to - from) * smooth * _dt()
  local target = from + step
  if (to - target)^2 <= _EPSILON^2 then target = to end
  return target
end

local function _linear(from, to, time)
  local step = (to - from > 0 and 1 or -1) * _TOTAL/time * _dt()
  return from + step
end

local function _render(enter, progress, x, y)
  local g = love.graphics
  local alpha = enter * 0xFF
  local cr, cg, cb = unpack(COLORS.NEUTRAL)
  g.push()
  g.translate(x - _WIDTH/2, y)
  g.setColor(cr/4, cg/4, cb/4, alpha)
  g.rectangle("fill", 0, 0, _WIDTH, _HEIGHT)
  g.setColor(cr, cg, cb, alpha)
  g.rectangle("fill", 0, 0, _WIDTH*(progress/_TOTAL), _HEIGHT)
  g.pop()
end


local HoldBar = Class({
  __includes = ELEMENT
})

function HoldBar:init(hold_action)
  ELEMENT.init(self)
  self.enter = 0
  self.progress = 0
  self.hold_action = hold_action
  self.timers = {}
end

function HoldBar:lock()
  self.locked = true
end

function HoldBar:unlock()
  self.locked = false
  self.progress = 0
end

function HoldBar:isLocked()
  return self.locked
end

function HoldBar:reset()
  self.progress = 0
end

function HoldBar:fadeIn()
  self.enter = _tween(self.enter, _TOTAL, _ENTER_SPEED)
end

function HoldBar:fadeOut()
  self.enter = _tween(self.enter, 0, _ENTER_SPEED)
end

function HoldBar:advance()
  self.progress = math.min(_linear(self.progress, _TOTAL, _TIME), _TOTAL)
end

function HoldBar:rewind()
  self.progress = math.max(_linear(self.progress, 0, _TIME), 0)
end

function HoldBar:update()
  local is_down = INPUT.isActionDown(self.hold_action)

  -- enter fade in
  if self.locked or not is_down then
    self:fadeOut()
  else
    self:fadeIn()
  end

  -- advance or rewind progress
  if self.enter <= 0 then self.progress = 0 end
  if not self.locked then
    if is_down then
      self:advance()
    else
      self:rewind()
    end
  end

  -- check progress
  if not self.locked and self.progress >= _TOTAL then
    self:removeTimer("advance")
    return true
  end
  return false
end

function HoldBar:draw(x, y)
  -- render bar
  if self.enter > 0 and self.progress > 0 then
    _render(self.enter, self.progress, x, y)
  end
end

return HoldBar

