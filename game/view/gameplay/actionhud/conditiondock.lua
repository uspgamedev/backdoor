
-- luacheck: globals love

local VIEWDEFS  = require 'view.definitions'
local COLORS    = require 'domain.definitions.colors'
local ELEMENT   = require "steaming.classes.primitives.element"
local Class     = require "steaming.extra_libs.hump.class"
local vec2      = require 'cpml' .vec2

local _MW = 16
local _PW = 2
local _HEIGHT = 48
local _SLOT_OFFSET = 55

local ConditionDock = Class {
  __includes = {ELEMENT}
}

function ConditionDock:destroy()
  for _, card in ipairs(self.cardviews) do
    card:kill()
  end
  ELEMENT.destroy(self)
end

function ConditionDock:getWidth()
  return 2 * (_MW+_PW) + VIEWDEFS.CARD_W + (self.slots - 1) * _SLOT_OFFSET
end

function ConditionDock:init(x, slots)
  local _, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
  self.slots = slots
  self.cardviews = {}
  self.pos = vec2(x, h - _HEIGHT/2)
end

function ConditionDock:getConditionsCount()
  return #self.cardviews
end

function ConditionDock:getCardMode() -- luacheck: no self
  return 'cond'
end

function ConditionDock:addCard(cardview)
  table.insert(self.cardviews, cardview)
end

function ConditionDock:getCard(slot_index)
  return self.cardviews[slot_index]
end

function ConditionDock:removeCard(slot_index)
  return table.remove(self.cardviews, slot_index)
end

function ConditionDock:getSlotPositionForIndex(i)
  local left = self.pos.x - self:getWidth()/2 + _MW + _PW
  return vec2(left + (i - 1) * _SLOT_OFFSET, self.pos.y - _HEIGHT)
end

function ConditionDock:getSlotPosition()
  return self:getSlotPositionForIndex(self:getConditionsCount() + 1)
end

function ConditionDock:draw()
  local g = love.graphics
  g.push()
  g.translate(self.pos:unpack())
  self:drawFG()
  g.pop()
end

function ConditionDock:drawFG()
  local g = love.graphics
  local width = self:getWidth()
  local left, right = -width/2, width/2
  local top, bottom = -_HEIGHT/2, _HEIGHT/2
  local shape = { left, bottom, left, 0, left + _MW, top, right - _MW, top,
                  right, 0, right, bottom }
  g.setColor(COLORS.DARK)
  g.polygon('fill', shape)
end

return ConditionDock
