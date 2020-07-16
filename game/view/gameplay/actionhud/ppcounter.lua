
local Class      = require "steaming.extra_libs.hump.class"
local vec2       = require 'cpml' .vec2
local DEFS       = require 'domain.definitions'
local COLORS     = require 'domain.definitions.colors'
local ELEMENT    = require "steaming.classes.primitives.element"
local RES        = require 'resources'

local _RADIUS = 35
local _BAR_WIDTH = 9
local _MARGIN = 6
local _SPEED = 3*math.pi/2

local PPCounter = Class{
  __includes = {ELEMENT}
}

function PPCounter:init()
  ELEMENT.init(self)

  self.texture = RES.loadTexture("wedge")

  self.pp = DEFS.MAX_PP
  self.angle = 0

end

function PPCounter:draw()
  local g = love.graphics -- luacheck: globals love



  g.setColor(COLORS.DARK)
  self:draw_bars()

  local stencil = function()
    local start_angle = -math.pi/2 + math.pi/DEFS.MAX_PP
    g.arc("fill", 0, 0, _RADIUS, start_angle,
                      self.angle + start_angle)
  end
  g.stencil(stencil, "replace", 1)
  g.setStencilTest("equal", 1)
  g.setColor(COLORS.PP)
  self:draw_bars()
  g.setStencilTest()

end

function PPCounter:draw_bars()
  local g = love.graphics -- luacheck: globals love
  local v1 = vec2(0, -_RADIUS)
  local v2 = v1:rotate(math.pi/DEFS.MAX_PP)
  v2 = v2 - v1
  v2 = v2*((v2:len()-_MARGIN)/v2:len())
  v2 = vec2(v1.x + v2.x, v1.y + v2.y)
  local v3 = v2 - v1
  v3.x = -v3.x
  v3 = v1 + v3

  local scale_x = (v2.x - v3.x)/self.texture:getWidth()
  local scale_y = _BAR_WIDTH/self.texture:getHeight()

  g.push()
  g.rotate(math.pi)
  for _ = 1, DEFS.MAX_PP do
    g.draw(self.texture, v3.x, v3.y, nil, scale_x, scale_y)
    g.rotate(2*math.pi/DEFS.MAX_PP)
  end
  g.pop()
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

return PPCounter
