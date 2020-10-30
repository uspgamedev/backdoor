
local ELEMENT   = require "steaming.classes.primitives.element"
local Class     = require "steaming.extra_libs.hump.class"
local Util      = require "steaming.util"

local BodyInspector = Class {
  __includes = { ELEMENT }
}

function BodyInspector:init(route)
  ELEMENT.init(self)
  self.route = route
  self.focus_index_index = nil
  self.focus_indexed = false
  self.bodies = { n = 0 }
end

function BodyInspector:focus(dir)
  self.focus_indexed = true
  if not self.focus_index then
    if dir == 'DOWN' then
      self.focus_index = 1
    else
      self.focus_index = self.bodies.n
    end
  end
end

function BodyInspector:unfocus()
  self.focus_indexed = false
  self.focus_index = nil
end

function BodyInspector:moveFocus(dir)
  if not self.focus_indexed then self.focus_index() end
  if dir == 'UP' then
    if self.focus_index == 1 then
      return false
    else
      self.focus_index = self.focus_index - 1
    end
  elseif dir == 'DOWN' then
    if self.focus_index == self.bodies.n then
      return false
    else
      self.focus_index = self.focus_index + 1
    end
  end
  return true
end

function BodyInspector:hasElements()
  return self.bodies.n > 0
end

function BodyInspector:getFocusedElement()
  return self.bodies[self.focus_index]
end

function BodyInspector:update(_)
  self.bodies = { n = 0 }
  for id in pairs(self.route.getPlayerActor():getVisibleBodies()) do
    self.bodies.n = self.bodies.n + 1
    self.bodies[self.bodies.n] = Util.findId(id)
  end
  if self.focus_index then
    self.focus_index = math.max(1, math.min(self.bodies.n, self.focus_index))
  end
end

function BodyInspector:draw()
end

return BodyInspector

