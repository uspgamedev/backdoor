

-- luacheck: globals love

local ACTIONDEFS = require 'domain.definitions.action'

local ENERGY_BAR = {}

local _BARSCALE = 5
local _SMOOTH_FACTOR = 0.2
local _MAX_ENERGY = ACTIONDEFS.MAX_ENERGY

local _barstates
local _preview
local _glow

function ENERGY_BAR.init()
  _barstates = {}
  _preview = 0
  _glow = {}
end

function ENERGY_BAR.setEnergyPreview(value)
  _preview = (value or 0) * ACTIONDEFS.EXHAUSTION_UNIT
end

function ENERGY_BAR.draw(actor, x, y, is_controlled)
  local g = love.graphics
  local energy = math.max(0, actor:getEnergy())
  local last = _barstates[actor:getId()] or 0
  local value = last + (energy - last)*_SMOOTH_FACTOR
  if math.abs(value) < 1 then
    value = 0
  end
  _barstates[actor:getId()] = value
  --local unit = actor:getSPD()*ACTIONDEFS.CYCLE_UNIT*_BARSCALE
  --local percent = math.fmod(value, unit)/unit
  local percent = value/_MAX_ENERGY
  local pi = math.pi
  local start = pi/2 + 3*pi/36
  local length = 2*pi/3
  local radius = 42
  g.push()
  g.translate(x, y)
  g.scale(1, 1/2)
  g.setLineWidth(8)
  g.setColor(1, 1, 1, 0.2)
  g.arc('line', 'open', 0, 0, radius, start, start + length, 32)
  g.setColor(1, 1, 1, 0.8)
  g.arc('line', 'open', 0, 0, radius, start, start + length * percent, 32)

  local glow = _glow[actor:getId()] or 0
  glow = glow + love.timer.getDelta()
  local alpha = 0.5 + 0.3*math.sin(2 * glow * 2 * math.pi)
  _glow[actor:getId()] = glow

  g.setColor(.8, .2, 0, alpha)
  if is_controlled then
    local top = start + length * percent
    g.arc('line', 'open', 0, 0, radius, top - _preview/_MAX_ENERGY, top, 32)
  elseif _preview > 0 then
    local controlled = actor:getSector():getRoute().getControlledActor()
    local turns = math.ceil(_preview / controlled:getSPD())
    local recovered = actor:getSPD() * turns
    g.arc('line', 'open', 0, 0, radius, start + length * percent,
                                        start + length * (percent +
                                                      recovered/_MAX_ENERGY),
                                        32)
  end
  for i=1,4 do
    g.setColor(0, 0, 0.4, 0.5)
    local r = start + length * i/_BARSCALE
    local w = length/100
    g.arc('line', 'open', 0, 0, radius, r-w, r+w, 32)
  end
  g.pop()
end

return ENERGY_BAR

