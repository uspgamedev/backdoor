
-- luacheck: globals MAIN_TIMER

local TweenValue    = require 'view.helpers.tweenvalue'
local CardView      = require 'view.card'
local PLAYSFX       = require 'helpers.playsfx'

local ANIM = require 'common.activity' ()

function ANIM:script(route, view, report)
  local delay = TweenValue(0)
  local action_hud = view.action_hud
  if report.actor == route:getControlledActor() then
    local cardview = CardView(report.card)
    local frontbuffer = view.frontbuffer
    local hand = action_hud.handview
    hand:addCard(cardview)
    cardview:register("HUD")
    PLAYSFX("draw-card")
    cardview:setPosition(frontbuffer:getTopCardPosition():unpack())
    self.wait(delay:set(0.2))
    cardview:setDrawTable("HUD_FX")
  end
  delay:kill()
end

return ANIM
