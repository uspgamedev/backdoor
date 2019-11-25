
local Util          = require "steaming.util"
local TweenValue    = require 'view.helpers.tweenvalue'
local VIEWDEFS      = require 'view.definitions'
local vec2          = require 'cpml' .vec2

local ANIM = require 'common.activity' ()

-- luacheck: globals MAIN_TIMER

function ANIM:script(route, view, report)
  local action_hud = view.action_hud
  local delay = TweenValue(0)
  if report.actor == route:getControlledActor() then
    local cardview = action_hud.handview.hand[report.card_index]
    action_hud.handview:removeCard(report.card_index)
    action_hud.handview.cardinfo:lockCard(cardview.card)
    cardview:setAlpha(1)
    cardview:setFocus(false)
    local ann = Util.findId('announcement')
    ann:lock()
    cardview:register("HUD_FX")
    local deferred = ann:interrupt()
    if deferred then self.wait(deferred) end
    ann:announce(cardview.card:getName())
    local dock = view.action_hud:getDockFor(cardview.card)
    local destination = dock:getSlotPosition()
    local mode = dock:getCardMode()

    local offset = vec2(0, -2*VIEWDEFS.CARD_H)
    cardview:addTimer("slide", MAIN_TIMER, "tween", .6, cardview,
                      {position = destination + offset}, 'out-cubic',
      function()
        cardview:setMode(mode)
        cardview:addTimer("wait", MAIN_TIMER, "after", .1,
              function()
                action_hud.handview.cardinfo:lockCard()
                action_hud:disableCardInfo()
                cardview:addTimer("final_slide", MAIN_TIMER, "tween", .6,
                                  cardview, {position = destination},
                                  'out-cubic',
                  function()
                    dock:addCard(cardview)
                    self.resume()
                  end)
              end)
      end)


    self.wait()
    ann:unlock()
  end
  delay:kill()
  return self
end

return ANIM
