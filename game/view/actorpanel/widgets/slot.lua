
local vec2        = require 'cpml' .vec2
local Node        = require 'view.node'
local FONT        = require 'view.helpers.font'
local TweenValue  = require 'view.helpers.tweenvalue'
local COLORS      = require 'domain.definitions.colors'
local RES         = require 'resources'
local Class       = require "steaming.extra_libs.hump.class"
local common      = require 'lux.common'

local _MG = 24
local _PD = 4
local _DECAY_TIME = 0.5

local Slot = Class({ __includes = { Node } })

Slot.SQRSIZE = 36

function Slot:init(x, y, label)
  Node.init(self)
  self:setPosition(x, y)
  self.label = label and label:lower()
  self.flash = TweenValue(0, 'linear')
  self.flashcolor = COLORS.FLASH_ANNOUNCE
  self.flashtime = 1
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
  self.flashcolor = color or self.flashcolor
  self.flashtime = seconds + _DECAY_TIME
  self.flash:snap(seconds + _DECAY_TIME)
  self.flash:set(0)
end

local function _flashFX(color, energy)
  energy = math.min(1, energy*2)
  if energy > 0.05 then
    return color*energy
  else
    return COLORS.BLACK
  end
end

function Slot:render(g)
  local sqsize = Slot.SQRSIZE
  local widget = self.widget
  g.setColor(COLORS.EMPTY)
  g.rectangle("fill", 0, 0, sqsize, sqsize)
  if widget then
    local icon = RES.loadTexture(widget:getIconTexture() or 'icon-none')
    local iw, ih = icon:getDimensions()
    local flashfx = _flashFX(self.flashcolor, self.flash:get() / self.flashtime)
    icon:setFilter('linear', 'linear')
    g.setColor(COLORS[widget:getRelatedAttr()] + flashfx)
    g.rectangle("fill", 0, 0, sqsize, sqsize)
    g.setColor(COLORS.BLACK + flashfx * 2)
    g.draw(icon, 0, 0, 0, sqsize/iw, sqsize/ih)
  elseif self.label then
    g.setColor(COLORS.BLACK)
    g.printf(self.label, 0, 0, sqsize, "center")
  end
end

return Slot

