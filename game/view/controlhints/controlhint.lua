local vec2    = require 'cpml' .vec2

local ControlHint = Class{
  __includes = { ELEMENT }
}

function ControlHint:init(x, y)
    ELEMENT.init(self)
    self:setSubtype("control_hints")

    self.pos = vec2(x, y)

    self.show = true
end

function ControlHint:toggleShow()
  self.show = not self.show
end

return ControlHint
