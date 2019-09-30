
-- luacheck: globals love

local VIEWDEFS  = require 'view.definitions'
local COLORS    = require 'domain.definitions.colors'
local ELEMENT   = require "steaming.classes.primitives.element"
local Class     = require "steaming.extra_libs.hump.class"
local vec2      = require 'cpml' .vec2

local _MW = 16
local _PW = 2
local _HEIGHT = 32

local EquipmentDock = Class {
  __includes = {ELEMENT}
}

function EquipmentDock.getWidth()
  return 2 * (_MW+_PW) + VIEWDEFS.CARD_W
end

function EquipmentDock:init(x)
  local _, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
  self.cardview = nil
  self.pos = vec2(x, h - _HEIGHT/2)
end

function EquipmentDock:isEmpty()
  return not self.cardview
end

function EquipmentDock:addCard(cardview, slot_index)
  self.cardview = cardview
end

function EquipmentDock:getCard()
  return self.cardview
end

function EquipmentDock:removeCard()
  local card = self.cardview
  self.cardview = nil
  return card
end

--Where to "insert" card
function EquipmentDock:getSlotPosition()
  return vec2(self.pos.x - self.getWidth()/2 + _MW + _PW,
              self.pos.y - VIEWDEFS.CARD_H/2 - _HEIGHT/2)
end

function EquipmentDock:draw()
  local g = love.graphics
  g.push()
  g.translate(self.pos:unpack())
  self:drawFG()
  g.pop()
end

function EquipmentDock:drawFG()
  local g = love.graphics
  local width = self.getWidth()
  local left, right = -width/2, width/2
  local top, bottom = -_HEIGHT/2, _HEIGHT/2
  local shape = { left, bottom, left, 0, left + _MW, top, right - _MW, top,
                  right, 0, right, bottom }
  g.setColor(COLORS.DARK)
  g.polygon('fill', shape)
end

return EquipmentDock
