
local Util          = require "steaming.util"
local Transmission  = require 'view.transmission'
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
  if report.actor == route:getControlledActor() then
    print "playing card"
    local cardview = action_hud.handview.hand[report.card_index]
    action_hud.handview:keepFocusedCard(false)
    action_hud:disableCardInfo()
    cardview:setAlpha(1)
    local ann = Util.findId('announcement')
    ann:lock()
    cardview:register("HUD_FX")
    print "raising card"
    self.wait(cardview:raise())
    print "raised card"
    ann:interrupt()
    --while ann:isBusy() do wait(1) end
    ann:announce(cardview.card:getName())
    local destination,color = _findPlayedCardViewDestination(cardview)
    print "transmiting card"
    self.wait(Transmission(cardview, destination, 0.5, color))
    ann:unlock()
    cardview:kill()
    action_hud.handview:removeCard(report.card_index)
  end
  print "ggkthx"
  return self
end

return ANIM

