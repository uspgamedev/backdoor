local vec2    = require 'cpml' .vec2
local Class   = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"

local ControlHint = Class{
  __includes = { ELEMENT }
}

function ControlHint:init(x, y)
    ELEMENT.init(self)
    self:setSubtype("control_hints")

    self.pos = vec2(x, y)

    self.show = false
    self.alpha = 0
    self.show_speed = 5
end

function ControlHint:update(dt)
  if self.show then
    self.alpha = math.min(self.alpha + self.show_speed*dt, 1)
  else
    self.alpha = math.max(self.alpha - self.show_speed*dt, 0)
  end
end

function ControlHint:setShow(v)
  self.show = v
end

return ControlHint
