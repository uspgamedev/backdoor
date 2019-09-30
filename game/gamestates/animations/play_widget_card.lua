
local Util          = require "steaming.util"
local TweenValue    = require 'view.helpers.tweenvalue'
local VIEWDEFS      = require 'view.definitions'
local Dissolve      = require 'view.dissolvecard'
local vec2          = require 'cpml' .vec2

local ANIM = require 'common.activity' ()

-- luacheck: no self

local function _findPlayedCardViewDestination(view, cardview)
  local hud = view.action_hud
  if cardview.card:isEquipment() then
    local placement  = cardview.card:getWidgetPlacement()
    if placement == "wieldable" then
      return hud:getWieldDockPosition(), hud.wielddock
    elseif placement == "wearable" then
      return hud:getWearDockPosition(), hud.weardock
    end
  else --Is a condition widget
    local slot = hud:getConditionsCount() + 1
    return hud:getCondDockPosition(slot), hud.conddock
  end
  return error("Not a valid placement for equipment widget")
end

function ANIM:script(route, view, report)
  local action_hud = view.action_hud
  local delay = TweenValue(0)
  if report.actor == route:getControlledActor() then
    local cardview = action_hud.handview.hand[report.card_index]
    action_hud.handview:removeCard(report.card_index)
    cardview:setAlpha(1)
    cardview:setFocus(false)
    local ann = Util.findId('announcement')
    ann:lock()
    cardview:register("HUD_FX")
    local deferred = ann:interrupt()
    if deferred then self.wait(deferred) end
    ann:announce(cardview.card:getName())
    local destination, dock = _findPlayedCardViewDestination(view, cardview)

    local offset = vec2(0, -2*VIEWDEFS.CARD_H)
    cardview:addTimer("slide", MAIN_TIMER, "tween", .6, cardview,
                      {position = destination + offset}, 'out-cubic',
      function()
        cardview:addTimer("wait", MAIN_TIMER, "after", .1,
              function()
                cardview:addTimer("final_slide", MAIN_TIMER, "tween", .6,
                                  cardview, {position = destination}, 'out-cubic',
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
