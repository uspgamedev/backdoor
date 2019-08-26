
local Transmission  = require 'view.transmission'
local TweenValue    = require 'view.helpers.tweenvalue'
local COLORS        = require 'domain.definitions.colors'
local CardView      = require 'view.card'

local ANIM = require 'common.activity' ()

function ANIM:script(route, view, report)
  local delay = TweenValue(0)
  local action_hud = view.action_hud
  if report.actor == route:getControlledActor() then
    local card_view = CardView(report.card)
    view.action_hud.handview:addCard(card_view)
    action_hud:disableCardInfo()
    local eqp_slot = view.actor.widgets.slots[1][1]
    Transmission(eqp_slot, card_view, 0.5, COLORS.FLASH_DRAW)
    self.wait(delay:set(0.2))
  end
  delay:kill()
end

return ANIM
