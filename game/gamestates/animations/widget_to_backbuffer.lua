
local Transmission  = require 'view.transmission'
local COLORS        = require 'domain.definitions.colors'

local ANIM = require 'common.activity' ()

function ANIM:script(route, view, report)
  if report.body == route:getControlledActor():getBody() then
    local widget_slot = view.actor:getWidgets():findCardSlot(report.widget_card)
    local backbuffer = view.backbuffer
    local color = COLORS.FLASH_DISCARD
    self.yield(Transmission(widget_slot, backbuffer, 0.5, color))
  end
  report.pending = false
end

return ANIM

