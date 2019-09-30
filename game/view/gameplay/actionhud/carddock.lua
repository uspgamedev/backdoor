
-- luacheck: globals love

local VIEWDEFS  = require 'view.definitions'
local COLORS    = require 'domain.definitions.colors'
local ELEMENT   = require "steaming.classes.primitives.element"
local Class     = require "steaming.extra_libs.hump.class"
local vec2      = require 'cpml' .vec2

local _MW = 16
local _PW = 2
local _HEIGHT = 32
local _SLOT_OFFSET = 8

local CardDock = Class {
  __includes = {ELEMENT}
}

function CardDock.widthFor(slots)
  return 2 * (_MW+_PW) + VIEWDEFS.CARD_W + (slots - 1) * _SLOT_OFFSET
end

function CardDock:init(x, slots)
  local _, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
  self.slots = slots
  self.cardviews = {}
  self.pos = vec2(x, h - _HEIGHT/2)
end

function CardDock:getOccupiedSlotCount()
  return #self.cardviews
end

function CardDock:addCard(cardview, slot_index)
  table.insert(self.cardviews, slot_index, cardview)
end

function CardDock:removeCard(slot_index)
  return table.remove(self.cardviews, slot_index)
end

function CardDock:getSlotPosition(i)
  local width = self.widthFor(self.slots)
  local left = self.pos.x - width/2 + _MW + _PW
  return vec2(left + (i - 1) * _SLOT_OFFSET, self.pos.y - VIEWDEFS.CARD_H/2 - _HEIGHT/2)
end

function CardDock:draw()
  local g = love.graphics
  g.push()
  g.translate(self.pos:unpack())
  self:drawFG()
  g.pop()
end

function CardDock:drawFG()
  local g = love.graphics
  local width = self.widthFor(self.slots)
  local left, right = -width/2, width/2
  local top, bottom = -_HEIGHT/2, _HEIGHT/2
  local shape = { left, bottom, left, 0, left + _MW, top, right - _MW, top,
                  right, 0, right, bottom }
  g.setColor(COLORS.DARK)
  g.polygon('fill', shape)
end

return CardDock
