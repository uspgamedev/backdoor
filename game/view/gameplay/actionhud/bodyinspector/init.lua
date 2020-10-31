
local ELEMENT   = require "steaming.classes.primitives.element"
local Class     = require "steaming.extra_libs.hump.class"
local Util      = require "steaming.util"

local BodyInspector = Class {
  __includes = { ELEMENT }
}

function BodyInspector:init(route)
  ELEMENT.init(self)
  self.route = route
  self.focus_index = nil
  self.focused = false
  self.bodies = { n = 0 }
end

function BodyInspector:focus(dir)
  self.focused = true
  self.focus_index = self.bodies.n
end

function BodyInspector:unfocus()
  self.focused = false
end

function BodyInspector:moveFocus(dir)
  if not self.focused then return false end
  if dir == 'UP' then
    if self.focus_index == 1 then
      return false
    else
      self.focus_index = self.focus_index - 1
    end
    return true
  elseif dir == 'DOWN' then
    if self.focus_index == self.bodies.n then
      return false
    else
      self.focus_index = self.focus_index + 1
    end
    return true
  end
  return false
end

function BodyInspector:hasElements()
  return self.bodies.n > 0
end

function BodyInspector:getFocusedElement()
  return self.bodies[self.focus_index]
end

local function _less(body1, body2)
  local i1, j1 = body1:getPos()
  local i2, j2 = body2:getPos()
  if i1 == i2 then
    return j1 < j2
  else
    return i1 < i2
  end
end

function BodyInspector:update(_)
  self.bodies = { n = 0 }
  for id in pairs(self.route.getPlayerActor():getVisibleBodies()) do
    self.bodies.n = self.bodies.n + 1
    self.bodies[self.bodies.n] = Util.findId(id)
  end
  table.sort(self.bodies, _less)
  if self.focus_index then
    self.focus_index = math.min(self.bodies.n, self.focus_index)
  end
  local sectorview = Util.findId('sector_view')
  if sectorview then
    sectorview:setTempTarget(self.focused and self:getFocusedElement())
  end
end

function BodyInspector:draw()
end

return BodyInspector

