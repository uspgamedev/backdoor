
local Util          = require "steaming.util"
local TweenValue    = require 'view.helpers.tweenvalue'
local Transmission  = require 'view.transmission'
local Dissolve      = require 'view.dissolvecard'
local COLORS        = require 'domain.definitions.colors'

local ANIM = require 'common.activity' ()

-- luacheck: no self

local function _findPlayedCardViewDestination(cardview)
  if cardview.card:isArt() then
    return Util.findId('backbuffer_view'), COLORS.FLASH_DISCARD
  elseif cardview.card:isWidget() then
    return Util.findId('actor_panel'):getWidgets():findCardSlot(cardview.card),
           COLORS.EQUIP
  end
  return error("Non card type encountered")
end

function ANIM:script(route, view, report)
  local action_hud = view.action_hud
  local delay = TweenValue(0)
  if report.actor == route:getControlledActor() then
    local cardview = action_hud.handview.hand[report.card_index]
    action_hud.handview:keepFocusedCard(false)
    action_hud:disableCardInfo()
    cardview:setAlpha(1)
    local ann = Util.findId('announcement')
    ann:lock()
    cardview:register("HUD_FX")
    self.wait(cardview:raise())
    local deferred = ann:interrupt()
    if deferred then self.wait(deferred) end
    ann:announce(cardview.card:getName())
    local destination,color = _findPlayedCardViewDestination(cardview)
    if not cardview.temporary then
      delay:set(0.25):andThen(function () cardview:kill() end)
      self.wait(Transmission(cardview, destination, 0.5, color))
    else
      delay:set(.8):andThen(function () cardview:kill() end)
      self.wait(Dissolve(cardview, .8))
    end
    ann:unlock()
    action_hud.handview:removeCard(report.card_index)
  end
  delay:kill()
  return self
end

return ANIM
