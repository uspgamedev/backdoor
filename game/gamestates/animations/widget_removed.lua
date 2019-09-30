
local Transmission  = require 'view.transmission'
local COLORS        = require 'domain.definitions.colors'

local ANIM = require 'common.activity' ()

function ANIM:script(route, view, report)
  if report.body == route:getControlledActor():getBody() then
    print(report.widget_card, "card")
    local widget_slot = view.actor:getWidgets():findCardSlot(report.widget_card)
    local backbuffer = view.backbuffer
    local color = COLORS.FLASH_DISCARD
    self.wait(Transmission(widget_slot, backbuffer, 0.5, color))
  end
end

return ANIM
