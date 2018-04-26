
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
  _glow = 0
end

function COOLDOWNBAR.setCooldownPreview(value)
  _preview = value or 0
end

function COOLDOWNBAR.draw(actor, x, y, show_preview)
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
  g.push()
  g.translate(x, y)
  g.scale(1, 1/2)
  g.setLineWidth(8)
  g.setColor(1, 1, 1, 0.2)
  g.arc('line', 'open', 0, 0, 36, 0, 2*math.pi, 32)
  g.setColor(1, 1, 1, 0.8)
  g.arc('line', 'open', 0, 0, 36, 0, percent*2*math.pi, 32)
  if show_preview then
    _glow = _glow + love.timer.getDelta()
    local alpha = 0.5 + 0.3*math.sin(2 * _glow * 2 * math.pi)
    g.setColor(1, 1, 0, alpha)
    g.arc('line', 'open', 0, 0, 36, 0, (_preview/unit)*2*math.pi, 32)
  end
  g.pop()
end

return COOLDOWNBAR

