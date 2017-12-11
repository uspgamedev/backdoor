
local INPUT = require 'input'
local DIR = require 'domain.definitions.dir'

local DIRECTIONAL = {}

local _DEADZONE = .4
local _DEADZONE_SQR = _DEADZONE * _DEADZONE
local _SIXTEENTH = math.pi / 8

local _POSITIONS = {
  c  = false,
  u  = 'up',
  d  = 'down',
  l  = 'left',
  r  = 'right',
  ld = 'downleft',
  lu = 'upleft',
  rd = 'downright',
  ru = 'upright',
}

local acos = math.acos
local sqrt = math.sqrt
local abs = math.abs
local used
function DIRECTIONAL.getFromAxes()
  local x, y = INPUT.getAxis('AXIS_X'), INPUT.getAxis('AXIS_Y')
  if x*x+y*y < _DEADZONE_SQR then
    used = false
    return false
  elseif not used then
    used = true
    if     x >  _DEADZONE and abs(y) < _DEADZONE then
      return 'right'
    elseif x < -_DEADZONE and abs(y) < _DEADZONE then
      return 'left'
    elseif y >  _DEADZONE and abs(x) < _DEADZONE then
      return 'down'
    elseif y < -_DEADZONE and abs(x) < _DEADZONE then
      return 'up'
    elseif y < 0 and x < 0 then
      return 'upleft'
    elseif y < 0 and x > 0 then
      return 'upright'
    elseif y > 0 and x < 0 then
      return 'downleft'
    elseif y > 0 and x > 0 then
      return 'downright'
    end
  end
end

local last_hat
function DIRECTIONAL.getFromHat()
  local dir = INPUT.getHat('HAT_DIRECTIONALS')
  if dir == last_hat then return false end
  last_hat = dir
  return _POSITIONS[dir]
end

return DIRECTIONAL

