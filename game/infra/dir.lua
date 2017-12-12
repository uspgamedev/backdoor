
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

local _OCTANTS = {}

function _OCTANTS.UP(x, y)
  return y/3 < x and x < -y/3
end

function _OCTANTS.RIGHT(x, y)
  return -x/3 < y and y < x/3
end

function _OCTANTS.DOWN(x, y)
  return -y/3 < x and x < y/3
end

function _OCTANTS.LEFT(x, y)
  return x/3 < y and y < -x/3
end

function _OCTANTS.UPLEFT(x, y)
  return 3*x <= y and y <= x/3
end

function _OCTANTS.UPRIGHT(x, y)
  return -3*x <= y and y <= -x/3
end

function _OCTANTS.DOWNRIGHT(x, y)
  return x/3 <= y and y <= 3*x
end

function _OCTANTS.DOWNLEFT(x, y)
  return -x/3 <= y and y <= -3*x
end

DIRECTIONALS.DEADZONE = _DEADZONE

function DIRECTIONALS.getFromAxes()
  local x, y = INPUT.getAxis('AXIS_X'), INPUT.getAxis('AXIS_Y')
  if x*x+y*y < _DEADZONE_SQR then
    return 'c'
  else
    for dir, enum in pairs(_DIR_TRANSLATE) do
      if _OCTANTS[dir](x, y) then
        return enum
      end
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

  if _last_hat then hat = false end
  if _last_axis then axis = false end

  local is_hat = hat == dir
  local is_axis = axis == dir

  if is_hat then _last_hat = hat end
  if is_axis then _last_axis = axis end

  return is_hat or is_axis or INPUT.wasActionPressed(direction)
end

function DIRECTIONALS.isDirectionDown(direction)
  local dir = _DIR_ENUM[_DIR_TRANSLATE[direction]]
  local hat = _DIR_ENUM[DIRECTIONALS.getFromHat()]
  local axis = _DIR_ENUM[DIRECTIONALS.getFromAxes()]
  return dir == hat or dir == axis or INPUT.isActionDown(direction)
end

return DIRECTIONALS

