
local HandView    = require 'view.hand'
local FocusBar    = require 'view.focusbar'

local _INFO_LAG = 2.0 -- seconds

local HUDAnimator = Class{
  __includes = { ELEMENT }
}

function HUDAnimator:init(route)

  ELEMENT.init(self)

  self.route = route

  -- Hand view
  self.handview = HandView(route)
  self.handview:addElement("HUD_BG", nil, "hand_view")
  Signal.register(
    "actor_draw",
    function(actor, card)
      self.handview:addCard(actor,card)
    end
  )

  -- Card info
  self.info_lag = false

  -- Focus bar
  self.focusbar = FocusBar(route)
  self.focusbar:addElement("HUD")

end

function HUDAnimator:getHandView()
  return self.handview
end

function HUDAnimator:hideLowerHUD()
  self.handview:hide()
  self.focusbar:hide()
end

function HUDAnimator:showLowerHUD()
  self.handview:show()
  self.focusbar:show()
end

function HUDAnimator:disableCardInfo()
  self.handview.cardinfo:hide()
  self.info_lag = false
end

function HUDAnimator:enableCardInfo()
  self.info_lag = 0
end

function HUDAnimator:isHandActive()
  return self.handview:isActive()
end

function HUDAnimator:activateHand()
  self.handview:activate()
end

function HUDAnimator:playCardAsArt(index)
  local view = self.handview.hand[index]
  view:playAsArt()
end

function HUDAnimator:moveHandFocus(dir)
  self.handview:moveFocus(dir)
  if self.info_lag then
    self.info_lag = 0
    self.handview.cardinfo:hide()
  end
end

function HUDAnimator:update(dt)

  -- If card info is enabled
  if self.info_lag then
    self.info_lag = math.min(_INFO_LAG, self.info_lag + dt)

    if self.info_lag >= _INFO_LAG and not self.handview.cardinfo:isVisible() then
      self.handview.cardinfo:show()
    end
  end

end

return HUDAnimator

