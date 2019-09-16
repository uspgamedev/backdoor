
-- luacheck: globals MAIN_TIMER

local TweenValue    = require 'view.helpers.tweenvalue'
local CardView      = require 'view.card'
local vec2          = require 'cpml' .vec2

local ANIM = require 'common.activity' ()

function ANIM:script(route, view, report)
  local delay = TweenValue(0)
  local action_hud = view.action_hud
  if report.actor == route:getControlledActor() then
    local cardview = CardView(report.card)
    local frontbuffer = view.frontbuffer
    local hand = view.action_hud.handview
    local start = vec2(frontbuffer:getPosition())
    local finish = vec2(hand:positionForIndex(hand:cardCount()))
    hand:addCard(cardview)
    action_hud:disableCardInfo()
    cardview:setOffset((start - finish):unpack())
    cardview:register("HUD")
    cardview:addTimer("slide", MAIN_TIMER, "tween", 0.5, cardview,
                      { offset = vec2() }, 'out-cubic')
    self.wait(delay:set(0.2))
    cardview:setDrawTable("HUD_FX")
  end
  delay:kill()
end

return ANIM
