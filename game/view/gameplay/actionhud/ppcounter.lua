
local Class      = require "steaming.extra_libs.hump.class"
local vec2       = require 'cpml' .vec2
local COLORS     = require 'domain.definitions.colors'
local ELEMENT    = require "steaming.classes.primitives.element"

local PPCounter = Class{
  __includes = {ELEMENT}
}

function PPCounter:init()
  ELEMENT.init(self)

  self.position = vec2()
  self.pp = 0
end

function PPCounter:draw()
  local g = love.graphics

  g.setColor(COLORS.PP)
  g.circle("line", self.position.x, self.position.y, 30)
end

function PPCounter:setPP(value)
  self.pp = value
end

function PPCounter:update(dt)
end

return PPCounter
