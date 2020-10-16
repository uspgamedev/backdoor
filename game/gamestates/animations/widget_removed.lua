
-- luacheck: globals MAIN_TIMER

local ANIM       = require 'common.activity' ()
local VIEWDEFS   = require 'view.definitions'
local TweenValue = require 'view.helpers.tweenvalue'
local Dissolve   = require 'view.dissolvecard'
local vec2       = require 'cpml' .vec2

function ANIM:script(route, view, report)
  local delay = TweenValue(0)
  if report.body == route:getPlayerActor():getBody() then
    local cardview = view.action_hud:removeWidgetCard(report.widget_card)
    local backbuffer = view.backbuffer
    local finish = backbuffer:getTopCardPosition()
    local offset = vec2(0, -2*VIEWDEFS.CARD_H)
    cardview:setMode("normal")
    cardview:addTimer("slide", MAIN_TIMER, "tween", .5, cardview,
                      { position = finish + offset }, 'out-cubic',
                    function()
                      if not cardview.card:isOneTimeOnly() then
                        cardview:addTimer("slide", MAIN_TIMER, "tween", .5, cardview,
                                          { position = finish}, 'out-cubic')
                        cardview:addTimer("wait", MAIN_TIMER, "after", .3,
                                          function ()
                                            cardview:addTimer("fadeout", MAIN_TIMER, "tween", .3,
                                                              cardview, {alpha = 0}, 'out-cubic',
                                                              function() cardview:kill() end)
                                          end)
                      else
                        self.wait(Dissolve(cardview, .5):andThen(
                          function()
                            cardview:kill()
                          end
                      ))
                      end
                    end)
    self.wait(delay:set(0.75))
  end
  delay:kill()
end

return ANIM
