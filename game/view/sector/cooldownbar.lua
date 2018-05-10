
local ACTIONDEFS = require 'domain.definitions.action'

local COOLDOWNBAR = {}

local _BARSCALE = 10
local _SMOOTH_FACTOR = 0.5

local _barstates
local _preview
local _glow

function COOLDOWNBAR.init()
  _barstates = {}
  _preview = 0
  _glow = {}
end

function COOLDOWNBAR.setCooldownPreview(value)
  _preview = value or 0
end

function COOLDOWNBAR.draw(actor, x, y, is_controlled)
  local g = love.graphics
  local cooldown = actor:getCooldown()
  local last = _barstates[actor:getId()] or 0
  local value = last + (cooldown - last)*_SMOOTH_FACTOR
  if math.abs(value) < 1 then
    value = 0
  end
  _barstates[actor:getId()] = value
  local unit = ACTIONDEFS.EXHAUSTION_UNIT*_BARSCALE
  local percent = math.fmod(value, unit)/unit
  local pi = math.pi
  local start = pi/2 + 2*pi/36
  local length = 2*pi/3
  g.push()
  g.translate(x, y)
  g.scale(1, 1/2)
  g.setLineWidth(8)
  g.setColor(1, 1, 1, 0.2)
  g.arc('line', 'open', 0, 0, 36, start, start + length, 32)
  g.setColor(1, 1, 1, 0.8)
  g.arc('line', 'open', 0, 0, 36, start, start + length * percent, 32)

  local glow = _glow[actor:getId()] or 0
  glow = glow + love.timer.getDelta()
  local alpha = 0.5 + 0.3*math.sin(2 * glow * 2 * math.pi)
  _glow[actor:getId()] = glow

  if is_controlled then
    g.setColor(1, 1, 0, alpha)
    g.arc('line', 'open', 0, 0, 36, start, start + (_preview/unit) * length, 32)
  elseif _preview > 0 then
    local controlled = actor:getSector():getRoute().getControlledActor()
    local turns = math.ceil(_preview / controlled:getSPD())
    local recovered = math.min(actor:getSPD() * turns, value)
    g.setColor(.8, .2, 0, alpha)
    g.arc('line', 'open', 0, 0, 36, start + (value - recovered) / unit * length,
                                    start + percent * length, 32)
  end
  g.pop()
end

return COOLDOWNBAR

