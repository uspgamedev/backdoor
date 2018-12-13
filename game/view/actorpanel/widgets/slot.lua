
local vec2    = require 'cpml' .vec2
local Node    = require 'view.node'
local FONT    = require 'view.helpers.font'
local COLORS  = require 'domain.definitions.colors'
local RES     = require 'resources'
local Class   = require "steaming.extra_libs.hump.class"
local common  = require 'lux.common'

local _MG = 24
local _PD = 4

local Slot = Class({ __includes = { Node } })

Slot.SQRSIZE = 36

function Slot:init(x, y, label)
  Node.init(self)
  self:setPosition(x, y)
  self.label = label and label:lower()
end

function Slot:setWidget(widget)
  self.widget = widget or false
end

function Slot:swap(other)
  self.widget, other.widget = other.widget, self.widget
end

function Slot:getPoint()
  return self:getGlobalPosition() + vec2(.5,.5) * Slot.SQRSIZE
end

function Slot:flashFor(seconds, color)
end

function Slot:render(g)
  local sqsize = Slot.SQRSIZE
  local widget = self.widget
  g.setColor(COLORS.EMPTY)
  g.rectangle("fill", 0, 0, sqsize, sqsize)
  if widget then
    local icon = RES.loadTexture(widget:getIconTexture() or 'icon-none')
    local iw, ih = icon:getDimensions()
    icon:setFilter('linear', 'linear')
    g.setColor(COLORS[widget:getRelatedAttr()])
    g.rectangle("fill", 0, 0, sqsize, sqsize)
    g.setColor(COLORS.BLACK)
    g.draw(icon, 0, 0, 0, sqsize/iw, sqsize/ih)
  elseif self.label then
    g.setColor(COLORS.BLACK)
    g.printf(self.label, 0, 0, sqsize, "center")
  end
end

return Slot

