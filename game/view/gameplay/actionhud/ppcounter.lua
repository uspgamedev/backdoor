
local Class      = require "steaming.extra_libs.hump.class"
local vec2       = require 'cpml' .vec2
local DEFS       = require 'domain.definitions'
local COLORS     = require 'domain.definitions.colors'
local ELEMENT    = require "steaming.classes.primitives.element"

local _RADIUS = 35
local _BAR_WIDTH = 10
local _MARGIN = 8
local _SPEED = 3*math.pi/2


local _stencil
local _draw_polygon

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


  g.stencil(_stencil, "replace", 1)
  g.setStencilTest("equal", 1)
  g.setColor(COLORS.HALF_VISIBLE)
  g.circle("fill", 0, 0, _RADIUS)
  g.setStencilTest("equal", 1)
  g.setColor(COLORS.PP)
  local start_angle = math.pi/DEFS.MAX_PP
  g.arc("fill", 0, 0, _RADIUS, -math.pi/2 + start_angle, -math.pi/2 + self.angle + start_angle)
  g.setStencilTest()
end

function PPCounter:setPP(value)
  self.pp = value
end

function PPCounter:update(dt)
  local target_angle = (self.pp/DEFS.MAX_PP)*2*math.pi
  if target_angle > self.angle then
    self.angle = math.min(self.angle + _SPEED*dt, target_angle)
  else
    self.angle = math.max(self.angle - _SPEED*dt, target_angle)
  end
end

--local functions
function _stencil()
  local g = love.graphics
  g.push()
  for i = 1, DEFS.MAX_PP do
    _draw_polygon()
    g.rotate(2*math.pi/DEFS.MAX_PP)
  end
  g.pop()
end

function _draw_polygon()
  local x, y = 0, -_RADIUS
  local angle = 2*math.pi/DEFS.MAX_PP
  local vertices = {} --Vertices of polygon
  local add = function(value)
                table.insert(vertices, value)
              end
  --add(x)
  --add(y)
  local v1 = vec2(x, y)
  local v2 = v1:rotate(angle/2)
  v2 = v2 - v1
  v2 = v2*((v2:len()-_MARGIN)/v2:len())
  v2 = vec2(x + v2.x, y + v2.y)
  add(v2.x)
  add(v2.y)
  local v3 = v2*((v2:len() - _BAR_WIDTH)/v2:len())
  add(v3.x)
  add(v3.y)
  local v4 = v1*((v1:len() - _BAR_WIDTH)/v1:len())
  --add(v4.x)
  --add(v4.y)
  local v5 = v3 - v4
  v5.x = -v5.x
  v5 = v4 + v5
  add(v5.x)
  add(v5.y)
  local v6 = v2 - v1
  v6.x = -v6.x
  v6 = v1 + v6
  add(v6.x)
  add(v6.y)

  local g = love.graphics
  g.polygon("fill", vertices)
end

return PPCounter
