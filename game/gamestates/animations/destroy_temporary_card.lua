
local Transmission  = require 'view.transmission'
local COLORS        = require 'domain.definitions.colors'
local Util          = require "steaming.util"

local ANIM = require 'common.activity' ()

function ANIM:script(route, view, report)
  if report.actor == route:getControlledActor() then
    local hand_view = view.action_hud.handview
    local card_index = report.card_index
    local cardview = hand_view.hand[card_index]
    self.wait(Transmission(cardview, {getPoint = function() return {x = 500, y = 500} end}, 0.5, COLORS.FLASH_DISCARD))
    hand_view:removeCard(card_index)
  end
end

return ANIM
