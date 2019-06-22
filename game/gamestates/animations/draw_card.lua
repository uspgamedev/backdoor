
local Transmission  = require 'view.transmission'
local COLORS        = require 'domain.definitions.colors'
local CardView      = require 'view.card'
local Util          = require "steaming.util"

local ANIM = require 'common.activity' ()

function ANIM:script(route, view, report)
  if report.actor == route:getControlledActor() then
    local card_view = CardView(report.card)
    view.action_hud.handview:addCard(card_view)
    local frontbuffer = Util.findId('frontbuffer_view')
    self.wait(Transmission(frontbuffer, card_view, 0.5, COLORS.FLASH_DRAW))
  end
end

return ANIM

