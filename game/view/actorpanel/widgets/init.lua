
local EQUIPMENTS  = require 'domain.definitions.equipments'
local FONT        = require 'view.helpers.font'
local COLORS      = require 'domain.definitions.colors'
local Node        = require 'view.node'
local Slot        = require 'view.actorpanel.widgets.slot'
local Class       = require "steaming.extra_libs.hump.class"

local _EQUIPMENTS = 1
local _TRAITS = 2
local _CONDITIONS = 3
local _PD = 4
local _MG = 24

local _WIDGETSTRING = {
  "EQUIPMENTS",
  "TRAITS",
  "CONDITIONS",
}

local Widgets = Class({ __includes = { Node } })

function Widgets:init(actor, x, y)
  Node.init(self)
  self:setPosition(x, y)
  self.font = FONT.get("Text", 20)
  self.actor = actor
  self.slots = {}
  local sqsize = Slot.SQRSIZE
  for i=1,3 do
    self.slots[i] = {}
    local n = (i == _EQUIPMENTS) and 2 or 5
    for j=1,n do
      local slot = Slot((j - 1) * (sqsize + _PD),
                        i*(_MG*2 + self.font:getHeight()),
                        i == _EQUIPMENTS and EQUIPMENTS[EQUIPMENTS[j]])
      self.slots[i][j] = slot
      self:addChild(slot)
    end
  end
end

function Widgets:findCardSlot(widget_card)
  for i=1,3 do
    for j=1,#self.slots[i] do
      local slot = self.slots[i][j]
      if slot.widget == widget_card then
        return slot
      end
    end
  end
end

function Widgets:getActiveEquipmentSlot()
  return self.slots[1][1]
end

function Widgets:updatePlacements()
  local equipment = self.slots[_EQUIPMENTS]
  for n,slot in ipairs(EQUIPMENTS) do
    local widget = self.actor:getBody():getEquipmentAt(slot)
    equipment[n]:setWidget(widget)
  end
end

function Widgets:updateTraits()
  local traits = self.slots[_TRAITS]
  local n = 0
  for _,widget in self.actor:getBody():eachWidget() do
    if not widget:getWidgetPlacement() and widget:isWidgetPermanent() then
      n = n + 1
      traits[n]:setWidget(widget)
    end
  end
  for i=n+1,5 do
    traits[i]:setWidget()
  end
end

function Widgets:updateConditions()
  local conditions = self.slots[_CONDITIONS]
  local n = 0
  for _,widget in self.actor:getBody():eachWidget() do
    if not widget:getWidgetPlacement() and not widget:isWidgetPermanent() then
      n = n + 1
      conditions[n]:setWidget(widget)
    end
  end
  for i=n+1,5 do
    conditions[i]:setWidget()
  end
end

function Widgets:process(_)
  self:updatePlacements()
  self:updateTraits()
  self:updateConditions()
end

function Widgets:render(g)
  self.font:set()
  g.push()
  for i=1,3 do
    g.translate(0, _MG*2)
    g.setColor(COLORS.NEUTRAL)
    g.print(_WIDGETSTRING[i], 0, 0)
    g.translate(0, self.font:getHeight())
  end
  g.pop()
end

return Widgets

