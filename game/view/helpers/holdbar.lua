
local INPUT = require 'infra.input'
local COLORS = require 'domain.definitions.colors'

local _TOTAL = 1
local _SPEED = 1/8
local _ENTER_SPEED = 1/10
local _EPSILON = 0.01
local _WIDTH = 64
local _HEIGHT = 16

local HoldBar = {}

local function _new(hold_action)
  return setmetatable({
                        enter = 0,
                        progress = 0,
                        hold_action = hold_action
                      },
                      { __index = HoldBar })
end

local function _advance(progress)
  local val = math.min(_TOTAL, progress + (_TOTAL - progress)*_SPEED)
  if _TOTAL - val <= _EPSILON then val = _TOTAL end
  return val
end

local function _rewind(progress)
  local val = math.max(0, progress - progress*_SPEED)
  if val <= _EPSILON then val = 0 end
  return val
end

local function _render(enter, progress, x, y)
  local g = love.graphics
  local alpha = progress*enter * 0xFF
  local cr, cg, cb = unpack(COLORS.NEUTRAL)
  g.push()
  g.translate(x - _WIDTH/2, y)
  g.setColor(cr/4, cg/4, cb/4, alpha)
  g.rectangle("fill", 0, 0, _WIDTH, _HEIGHT)
  g.setColor(cr, cg, cb, alpha)
  g.rectangle("fill", 0, 0, _WIDTH*(progress/_TOTAL), _HEIGHT)
  g.pop()
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

function HoldBar:holdAndDraw(x, y)
  local is_down = INPUT.isDown(self.hold_action)

  -- enter fade in
  if self.locked or not is_down then
    self.enter = math.max(0, self.enter - _ENTER_SPEED)
  else
    self.enter = math.min(1, self.enter + _ENTER_SPEED)
  end

  -- advance or rewind progress
  if not self.locked then
    if is_down then
      if not self.locked then self.progress = _advance(self.progress) end
    else
      if not self.locked then self.progress = _rewind(self.progress) end
    end
  end

  -- check progress
  if self.progress > 0 then _render(self.enter, self.progress, x, y) end
  if not self.locked and self.progress == _TOTAL then
    return true
  end
  return false
end

return { new = _new }

