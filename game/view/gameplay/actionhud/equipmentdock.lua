
-- luacheck: globals love MAIN_TIMER

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
  ELEMENT.init(self)
  local _, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
  self.cardview = nil
  self.pos = vec2(x, h - _HEIGHT/2)
  self.top = _HEIGHT/2
end

function EquipmentDock:destroy()
  if self.cardview then
    self.cardview:kill()
  end
  ELEMENT.destroy(self)
end

function EquipmentDock:isEmpty()
  return not self.cardview
end

function EquipmentDock:getCardMode() -- luacheck: no self
  return 'equip'
end

--[[
 Optional has_card variable simulates the dock having a card,
 even if it actually hasn't
]]
function EquipmentDock:updateDockPosition(has_card)
  local pos = self.cardview or has_card and -_HEIGHT/2 or _HEIGHT/2
  self:removeTimer("update_top_pos", MAIN_TIMER)
  self:addTimer("update_top_pos", MAIN_TIMER, "tween", .25, self,
                {top = pos}, 'in-out-back')
end

function EquipmentDock:addCard(cardview)
  self.cardview = cardview
end

function EquipmentDock:getCard()
  return self.cardview
end

function EquipmentDock:getFocusedCard()
  return self.cardview
end

function EquipmentDock:getFocusedElement()
  return self.cardview.card
end

function EquipmentDock:hasElements()
  return not not self.cardview
end

function EquipmentDock:focus()
  if self.cardview then
    self.cardview:setFocus(true)
  end
end

function EquipmentDock:unfocus()
  if self.cardview then
    self.cardview:setFocus(false)
  end
end

function EquipmentDock:moveFocus(dir) -- luacheck: no self
  self:focus()
  return dir == 'NONE'
end

function EquipmentDock:removeCard()
  local card = self.cardview
  self.cardview = nil
  self:updateDockPosition()
  return card
end

--Where to "insert" card
function EquipmentDock:getAvailableSlotPosition()
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
  local top, bottom = self.top, _HEIGHT/2
  local shape = { left, bottom, left, top + _HEIGHT/2, left + _MW, top, right - _MW, top,
                  right, top + _HEIGHT/2, right, bottom }
  g.setColor(COLORS.DARK)
  g.polygon('fill', shape)
end

return EquipmentDock
