
local RANDOM        = require 'common.random'
local DIRECTIONALS  = require 'infra.dir'
local LONG_WALK     = require 'view.helpers.long_walk'
local ADJACENCY     = require 'view.helpers.adjacency'
local INPUT         = require 'input'
local DEFS          = require 'domain.definitions'
local VIEWDEFS      = require 'view.definitions'
local COLORS        = require 'domain.definitions.colors'
local HandView      = require 'view.hand'
local FocusBar      = require 'view.focusbar'
local HoldBar       = require 'view.helpers.holdbar'
local Transmission  = require 'view.transmission'
local vec2          = require 'cpml' .vec2
local Util          = require "steaming.util"
local Class         = require "steaming.extra_libs.hump.class"
local Signal        = require "steaming.extra_libs.hump.signal"
local ELEMENT       = require "steaming.classes.primitives.element"

local _INFO_LAG = 2.0 -- seconds

local ActionHUD = Class{
  __includes = { ELEMENT }
}

-- [[ Constant Variables ]]--

ActionHUD.INTERFACE_COMMANDS = {
  INSPECT_MENU = "INSPECT_MENU",
  SAVE_QUIT = "SAVE_QUIT",
  USE_READY_ABILITY = "USE_READY_ABILITY",
  READY_ABILITY_ACTION = "READY_ABILITY"
}

--[[ Basic methods ]]--

function ActionHUD:init(route)

  ELEMENT.init(self)

  self.route = route

  -- Hand view
  self.handview = HandView(route)
  self.handview:register("HUD_BG", nil, "hand_view")
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

  -- HUD state (player turn or not)
  self.player_turn = false

  -- Card info
  self.info_lag = false

  -- Focus bar
  self.focusbar = FocusBar(route)
  self.focusbar:register("HUD")

  -- Hold bar
  local w,h = VIEWDEFS.VIEWPORT_DIMENSIONS()
  self.holdbar = HoldBar{'EXTRA'}
  self.holdbar:setPosition(vec2(w,h)/2)
  self.holdbar:lock()
  self.holdbar:register("HUD")
  self.justheld = false
  self.holdbar_is_unlockable = true

  -- Long walk variables
  self.alert = false
  self.long_walk = false
  self.adjacency = {}
  ADJACENCY.unset(self.adjacency)

  -- Inspector mode
  self.inspecting = false
end

function ActionHUD:destroy()
  self.handview:destroy()
  self.focusbar:destroy()
  ELEMENT.destroy(self)
end

function ActionHUD:isAnimating()
  return self.handview:isAnimating()
end

function ActionHUD:activateAbility()
  self.handview:keepFocusedCard(true)
  self.handview:hide()
end

function ActionHUD:enableTurn()
  self.player_turn = true
  if not self.justheld then
    self.holdbar:unlock()
  end
end

function ActionHUD:disableTurn()
  self.player_turn = false
  self.holdbar:lock()
end

function ActionHUD:getHandView()
  return self.handview
end

function ActionHUD:disableCardInfo()
  self.handview.cardinfo:hide()
  self.info_lag = false
end

function ActionHUD:enableCardInfo()
  self.info_lag = self.info_lag or 0
end

function ActionHUD:isHandActive()
  return self.handview:isActive()
end

local function _findPlayedCardViewDestination(cardview)
  if cardview.card:isArt() then
    return Util.findId('backbuffer_view')
  elseif cardview.card:isWidget() then
    return Util.findId('actor_panel'):getWidgets():findCardSlot(cardview.card)
  end
end

function ActionHUD:playCard(index)
  local cardview = self.handview.hand[index]
  MAIN_TIMER:script(function(wait)
    self.handview:keepFocusedCard(false)
    self:disableCardInfo()
    cardview:setAlpha(1)
    local ann = Util.findId('announcement')
    ann:lock()
    cardview:register("HUD_FX")
    cardview:addTimer(
      nil, MAIN_TIMER, 'tween', 0.2, cardview,
      { position = cardview.position + vec2(0,-200) }, 'out-cubic'
    )
    wait(0.2)
    ann:interrupt()
    while ann:isBusy() do wait(1) end
    ann:announce(cardview.card:getName())
    local destination = _findPlayedCardViewDestination(cardview)
    local bends = RANDOM.safeGenerate(3, 10)
    Transmission(cardview, destination,
                 COLORS.FLASH_DISCARD, nil, bends):register("HUD_FX")
    cardview:flashFor(0.5, COLORS.FLASH_DISCARD)
    destination:flashFor(0.5, COLORS.FLASH_DISCARD)
    wait(0.5)
    ann:unlock()
    cardview:kill()
  end)
end

function ActionHUD:moveHandFocus(dir)
  self.handview:moveFocus(dir)
  self:resetCardInfoLag()
end

function ActionHUD:resetCardInfoLag()
  if self.info_lag then
    self.info_lag = 0
    self.handview.cardinfo:hide()
  end
end

function ActionHUD:sendAlert(flag)
  self.alert = self.alert or flag
end

--[[ INPUT methods ]]--

function ActionHUD:wasAnyPressed()
  return INPUT.wasAnyPressed()
end

function ActionHUD:actionRequested()
  local action_request
  local dir = DIRECTIONALS.hasDirectionTriggered()
  if dir then
    if INPUT.isActionDown('ACTION_4') and LONG_WALK.isAllowed(self) then
      LONG_WALK.start(self, dir)
    else
      action_request = {DEFS.ACTION.MOVE, dir}
    end
  end

  local player_focused = self.route.getControlledActor():isFocused()
  if INPUT.wasActionPressed('CONFIRM') then
    if player_focused then
      local card_index = self.handview:getFocus()
      if card_index > 0 then
        action_request = {DEFS.ACTION.PLAY_CARD, card_index}
      end
    else
      action_request = {DEFS.ACTION.INTERACT}
    end
  elseif INPUT.wasActionPressed('CANCEL') then
    action_request = {DEFS.ACTION.IDLE}
  elseif INPUT.wasActionPressed('SPECIAL') then
    action_request = {ActionHUD.INTERFACE_COMMANDS.USE_READY_ABILITY}
  elseif INPUT.wasActionPressed('ACTION_3') then
    action_request = {ActionHUD.INTERFACE_COMMANDS.READY_ABILITY_ACTION}
  elseif INPUT.wasActionPressed('ACTION_2') then
    if player_focused then
      self:moveHandFocus('LEFT')
    else
      action_request = {DEFS.ACTION.RECEIVE_PACK}
    end
  elseif INPUT.wasActionPressed('ACTION_1') then
    if player_focused then
      self:moveHandFocus('RIGHT')
    end
  elseif INPUT.wasActionPressed('PAUSE') then
    action_request = {ActionHUD.INTERFACE_COMMANDS.SAVE_QUIT}
  end

  if self.justheld and self.player_turn
                   and not INPUT.isActionDown('EXTRA') then
    self.holdbar:unlock()
    self.justheld = false
  end

  if self.holdbar:confirmed() then
    self.holdbar:reset()
    self.holdbar:lock()
    self.justheld = true
    action_request = {DEFS.ACTION.DRAW_NEW_HAND}
  end

  -- choose action
  if self.long_walk then
    if not action_request and LONG_WALK.continue(self) then
      action_request = {DEFS.ACTION.MOVE, self.long_walk}
    else
      self.long_walk = false
    end
  end

  if not self.inspecting and action_request then
    self:resetCardInfoLag()
    return unpack(action_request)
  end

  return false
end

--[[ Update ]]--

local function _disableHUDElements(self)
  self.handview:hide()
  self:disableCardInfo()
  if self.handview:isActive() then
    self.handview:deactivate()
  end
end

local function _startInspect(self)
  self.inspecting = true
  self.holdbar:lock()
end

local function _endInspect(self)
  self.inspecting = false
  if not self.justheld and self.holdbar:isLocked()
                       and self.holdbar_is_unlockable then
    self.holdbar:unlock()
  end
end

function ActionHUD:update(dt)
  --Checks if player can draw a new hand
  local player = self.route.getControlledActor()
  if player:getPP() < player:getBody():getConsumption() and
     not self.holdbar:isLocked() then
    self.holdbar:lock()
    self.holdbar_is_unlockable = false
  elseif player:getPP() >= player:getBody():getConsumption() then
    self.holdbar_is_unlockable = true
  end

  -- Input alerts long walk
  if INPUT.wasAnyPressed(0.5) then
    self.alert = true
  end

  if self.player_turn then
    local control_hints = Util.findSubtype("control_hints")
    if control_hints then
      for button in pairs(control_hints) do
          button:setShow(INPUT.isActionDown('HELP'))
      end
    end
    if self.route.getControlledActor():isFocused() then
      self.focusbar:show()
      if INPUT.isActionDown('ACTION_4') then
        self.handview:hide()
        self:disableCardInfo()
        if self.handview:isActive() then
          self.handview:deactivate()
        end
        _startInspect(self)
      else
        self.handview:show()
        self:enableCardInfo()
        if not self.handview:isActive() then
          self.handview:activate()
        end
        _endInspect(self)
      end
    else
      _endInspect(self)
      self.focusbar:hide()
      _disableHUDElements(self)
    end
  else
    _endInspect(self)
    _disableHUDElements(self)
  end

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
