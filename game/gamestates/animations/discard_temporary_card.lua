
local Dissolve      = require 'view.dissolvecard'
local COLORS        = require 'domain.definitions.colors'
local Util          = require "steaming.util"

local ANIM = require 'common.activity' ()

function ANIM:script(route, view, report)
  if report.actor == route:getControlledActor() then
    local hand_view = view.action_hud.handview
    local card_index = report.card_index
    local cardview = hand_view.hand[card_index]
    cardview:setFocus(false)
    hand_view:removeCard(card_index)
    self.wait(Dissolve(cardview, .5))
    cardview:kill()
  end
end

return ANIM
