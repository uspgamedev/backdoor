
local INPUT = require 'input'
local DIR = require 'domain.definitions.dir'

local pi    = math.pi
local abs   = math.abs
local atan2 = math.atan2

local DIRECTIONALS = {}

local _DEADZONE = .5
local _DEADZONE_SQR = _DEADZONE * _DEADZONE
local _SIXTEENTH = math.pi / 8

local _DIR_ENUM = {
  c  = false,
  u  = 1,
  r  = 2,
  d  = 3,
  l  = 4,
  lu = 5,
  ru = 6,
  rd = 7,
  ld = 8,
}

local _DIR_TRANSLATE = {
  UP        = 'u',
  RIGHT     = 'r',
  DOWN      = 'd',
  LEFT      = 'l',
  UPLEFT    = 'lu',
  UPRIGHT   = 'ru',
  DOWNRIGHT = 'rd',
  DOWNLEFT  = 'ld',
}

local _ANGLES = {}
for i = 0, 7 do
  _ANGLES[i*2+1] = i*pi/8
  _ANGLES[i*2+2] = -i*pi/8
end

DIRECTIONALS.DEADZONE = _DEADZONE

function DIRECTIONALS.getFromAxes()
  local x, y = INPUT.getAxis('AXIS_X'), INPUT.getAxis('AXIS_Y')
  if x*x+y*y < _DEADZONE_SQR then
    return 'c'
  else
    if     x >  _DEADZONE and abs(y) < _DEADZONE then
      return 'r'
    elseif x < -_DEADZONE and abs(y) < _DEADZONE then
      return 'l'
    elseif y >  _DEADZONE and abs(x) < _DEADZONE then
      return 'd'
    elseif y < -_DEADZONE and abs(x) < _DEADZONE then
      return 'u'
    elseif y < 0 and x < 0 then
      return 'lu'
    elseif y < 0 and x > 0 then
      return 'ru'
    elseif y > 0 and x < 0 then
      return 'ld'
    elseif y > 0 and x > 0 then
      return 'rd'
    end
  end
  return false
end

function DIRECTIONALS.getFromHat()
  return INPUT.getHat('HAT_DIRECTIONALS')
end

local _last_axis
local _last_hat

function DIRECTIONALS.wasDirectionTriggered(direction)
  local dir = _DIR_ENUM[_DIR_TRANSLATE[direction]]
  local hat = _DIR_ENUM[DIRECTIONALS.getFromHat()]
  local axis = _DIR_ENUM[DIRECTIONALS.getFromAxes()]

  if not hat then _last_hat = false end
  if not axis then _last_axis = false end

  if hat == _last_hat then hat = false end
  if axis == _last_axis then axis = false end

  if hat == dir then _last_hat = hat end
  if axis == dir then _last_axis = axis end

  return hat == dir or axis == dir or INPUT.wasActionPressed(direction)
end

return DIRECTIONALS

