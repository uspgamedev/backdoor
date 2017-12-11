
local INPUT = require 'input'
local DIR = require 'domain.definitions.dir'

local DIRECTIONALS = {}

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

local abs = math.abs

local _used
local _last_hat

DIRECTIONALS.DEADZONE = _DEADZONE

function DIRECTIONALS.getFromAxes()
  local x, y = INPUT.getAxis('AXIS_X'), INPUT.getAxis('AXIS_Y')
  if x*x+y*y < _DEADZONE_SQR then
    _used = false
    return false
  elseif not _used then
    _used = true
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

function DIRECTIONALS.getFromHat()
  local dir = INPUT.getHat('HAT_DIRECTIONALS')
  if dir == _last_hat then return false end
  _last_hat = dir
  return _POSITIONS[dir]
end

return DIRECTIONALS

