
-- luacheck: globals love

local VIEWDEFS  = require 'view.definitions'
local COLORS    = require 'domain.definitions.colors'
local ELEMENT   = require "steaming.classes.primitives.element"
local Class     = require "steaming.extra_libs.hump.class"
local vec2      = require 'cpml' .vec2

local _MW = 8
local _MH = 16
local _PW = 2
local _HEIGHT = 48
local _SLOT_OFFSET = 55
local _MAX_COND_PER_LINE = 4

local ConditionDock = Class {
  __includes = {ELEMENT}
}

function ConditionDock:init(x)
  ELEMENT.init(self)
  local _, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
  self.cardviews = {}
  self.pos = vec2(x, h - _HEIGHT/2)
  self.top = _HEIGHT/2
end

function ConditionDock:destroy()
  for i = 1, self.slots do
    local card = self.cardviews[i]
    if card then
      card:kill()
    end
  end
  ELEMENT.destroy(self)
end

function ConditionDock:getWidth()
  return 2 * (_MW+_PW) + VIEWDEFS.CARD_W + (_MAX_COND_PER_LINE - 1) * _SLOT_OFFSET
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
  local cardview = table.remove(self.cardviews, slot_index)
  self:updateConditionsPositions()
  return cardview
end

function ConditionDock:getSlotPositionForIndex(i, number_slots)
  --Optional variable to simulate a different sized dock
  number_slots = number_slots or self:getConditionsCount()
  local levels = math.ceil(number_slots/_MAX_COND_PER_LINE)
  local left = self.pos.x - self:getWidth()/2
  local division = self:getWidth()/(math.min(number_slots,_MAX_COND_PER_LINE) + 1)
  --[[
    This magic number compensates for the charge counter slightly leaving
    the condition widget, so that visually they all look more centralized in the
    condition dock
  ]]
  local cond_fix = 18
  local cond_w = VIEWDEFS.CARD_W * VIEWDEFS.CARD_COND_SCALE_X + cond_fix
  local cond_level = levels - math.ceil(i/_MAX_COND_PER_LINE) + 1
  local y = self.pos.y - _HEIGHT*cond_level - _MH*(cond_level-1)

  return vec2(left + ((i-1)%(_MAX_COND_PER_LINE) + 1) * division - cond_w/2, y)
end

function ConditionDock:getAvailableSlotPosition()
  local count = self:getConditionsCount()
    return self:getSlotPositionForIndex(count + 1, count + 1)
end

function ConditionDock:updateConditionsPositions(number_slots)
  number_slots = number_slots or self:getConditionsCount()

  --Update dock background
  local levels = math.ceil(number_slots/_MAX_COND_PER_LINE)
  self:removeTimer("update_top_pos", MAIN_TIMER)
  self:addTimer("update_top_pos", MAIN_TIMER, "tween", .25, self,
                {top = _HEIGHT/2 -_HEIGHT*levels - _MH *(levels - 1)},
                'in-out-back')

  --Update conditions
  for i, cond in ipairs(self.cardviews) do
    cond:removeTimer("update_cond_pos", MAIN_TIMER)
    cond:removeTimer("update_cond_pos_delay", MAIN_TIMER)

    cond:addTimer("update_cond_pos_delay", MAIN_TIMER, "after", .045*i,
      function()
        cond:addTimer("update_cond_pos", MAIN_TIMER, "tween", .2, cond,
                      {position = self:getSlotPositionForIndex(i, number_slots)},
                      'out-back')
      end
    )
  end

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
  local bottom = _HEIGHT/2
  local top = self.top
  local shape = { left, bottom, left, top + _HEIGHT/2, left + _MW, top, right - _MW, top,
                  right, top + _HEIGHT/2, right, bottom }

  g.setColor(COLORS.DARK)
  g.polygon('fill', shape)
end

return ConditionDock
