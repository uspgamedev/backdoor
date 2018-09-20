
local HandView    = require 'view.hand'
local FocusBar    = require 'view.focusbar'
local vec2        = require 'cpml' .vec2

local _INFO_LAG = 2.0 -- seconds

local ActionHUD = Class{
  __includes = { ELEMENT }
}

function ActionHUD:init(route)

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
  Signal.register(
    "actor_remove_card",
    function(actor, index, discarded)
      self.handview:removeCard(actor, index, discarded)
    end
  )

  -- Card info
  self.info_lag = false

  -- Focus bar
  self.focusbar = FocusBar(route)
  self.focusbar:addElement("HUD")

  -- View mode
  self.mode = 'exploration'

end

function ActionHUD:isAnimating()
  return self.handview:isAnimating()
end

function ActionHUD:setExplorationMode()
  self.mode = 'exploration'
end

function ActionHUD:setFocusMode()
  self.mode = 'focus'
end

function ActionHUD:activateHand()
  self.handview:show()
  self.handview:activate()
end

function ActionHUD:deactivateHand()
  self.handview:deactivate()
end

function ActionHUD:activateAbility()
  self.handview:keepFocusedCard(true)
  self.handview:hide()
end

function ActionHUD:activateTurn()
  if self.route.getControlledActor():isFocused() then
    self.focusbar:show()
  else
    self.focusbar:hide()
  end
  if self.handview:isActive() then
    self.handview:show()
  else
    self.handview:hide()
  end
  self:disableCardInfo()
end

function ActionHUD:deactivateState()
  self.handview:hide()
  self.focusbar:hide()
end

function ActionHUD:getHandView()
  return self.handview
end

function ActionHUD:hideLowerHUD()
  self.handview:hide()
  self.focusbar:hide()
end

function ActionHUD:showLowerHUD()
  self.handview:show()
  self.focusbar:show()
end

function ActionHUD:disableCardInfo()
  self.handview.cardinfo:hide()
  self.info_lag = false
end

function ActionHUD:enableCardInfo()
  self.info_lag = 0
end

function ActionHUD:isHandActive()
  return self.handview:isActive()
end

function ActionHUD:playCardAsArt(index)
  local cardview = self.handview.hand[index]
  MAIN_TIMER:script(function(wait)
    self.handview:keepFocusedCard(false)
    self:disableCardInfo()
    cardview:setAlpha(1)
    local ann = Util.findId('announcement')
    ann:lock()
    cardview:addElement("HUD_FX")
    cardview:addTimer(
      nil, MAIN_TIMER, 'tween', 0.2, cardview,
      { position = cardview.position + vec2(0,-200) }, 'out-cubic'
    )
    wait(0.2)
    ann:interrupt()
    while ann:isBusy() do wait(1) end
    ann:announce(cardview.card:getName(), cardview,
                 Util.findId('backbuffer_view'))
    cardview:flashFor(0.5)
    wait(0.5)
    ann:unlock()
    cardview:kill()
  end)
end

function ActionHUD:moveHandFocus(dir)
  self.handview:moveFocus(dir)
  if self.info_lag then
    self.info_lag = 0
    self.handview.cardinfo:hide()
  end
end

function ActionHUD:update(dt)

  -- If card info is enabled
  if self.info_lag then
    self.info_lag = math.min(_INFO_LAG, self.info_lag + dt)

    if self.info_lag >= _INFO_LAG
       and not self.handview.cardinfo:isVisible() then
      self.handview.cardinfo:show()
    end
  end

end

return ActionHUD

