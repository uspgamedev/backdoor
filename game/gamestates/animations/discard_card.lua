
-- luacheck: globals MAIN_TIMER

local TweenValue    = require 'view.helpers.tweenvalue'
local vec2          = require 'cpml' .vec2

local ANIM = require 'common.activity' ()

function ANIM:script(route, view, report)
  local delay = TweenValue(0)
  local action_hud = view.action_hud
  if report.actor == route:getControlledActor() then
    local card_index = report.card_index
    local backbuffer = view.backbuffer
    local hand = action_hud.handview
    local cardview = hand.hand[card_index]
    local finish = backbuffer:getTopCardPosition()
    hand:removeCard(card_index)
    action_hud:disableCardInfo()
    cardview:setFocus(false)
    cardview:register("HUD")
    cardview:addTimer("slide", MAIN_TIMER, "tween", .5, cardview,
                      { position = finish }, 'out-cubic')
    cardview:addTimer("wait", MAIN_TIMER, "after", .3,
                      function ()
                        cardview:addTimer("fadeout", MAIN_TIMER, "tween", .3,
                                          cardview, {alpha = 0}, 'out-cubic',
                                          function() cardview:kill() end)
                      end)
    self.wait(delay:set(0.25))
  end
  delay:kill()
end

return ANIM
