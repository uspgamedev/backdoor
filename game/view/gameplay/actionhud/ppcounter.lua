
local Class      = require "steaming.extra_libs.hump.class"
local vec2       = require 'cpml' .vec2
local DEFS       = require 'domain.definitions'
local COLORS     = require 'domain.definitions.colors'
local ELEMENT    = require "steaming.classes.primitives.element"

local _RADIUS = 28
local _CIRCLE_WIDTH = 5
local _SEPARATOR_WIDTH = 5

local _stencil

local PPCounter = Class{
  __includes = {ELEMENT}
}

function PPCounter:init()
  ELEMENT.init(self)

  self.pp = DEFS.MAX_PP
  self.angle = 0

end

function PPCounter:draw()
  local g = love.graphics

  g.setColor(COLORS.PP)
  love.graphics.stencil(_stencil, "replace", 1)
  love.graphics.setStencilTest("less", 1)
  g.arc("fill", 0, 0, _RADIUS, -math.pi/2, -math.pi/2 + self.angle)
  love.graphics.setStencilTest()
end

function PPCounter:setPP(value)
  self.pp = value
end

function PPCounter:update(dt)
  local target_angle = (self.pp/DEFS.MAX_PP)*2*math.pi
  self.angle = self.angle - (self.angle - target_angle)*.9*dt
end

--local functions
function _stencil()
  local g = love.graphics
  g.push()
  g.rotate(2*math.pi/DEFS.MAX_PP)
  g.setLineWidth(_SEPARATOR_WIDTH)
  for i = 1, DEFS.MAX_PP do
    g.line(0, 0, 0, -_RADIUS-_CIRCLE_WIDTH)
    g.rotate(2*math.pi/DEFS.MAX_PP)
  end
  g.pop()
  g.circle("fill", 0, 0, _RADIUS - _CIRCLE_WIDTH)
end

return PPCounter
