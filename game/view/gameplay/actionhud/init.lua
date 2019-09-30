
-- luacheck: globals MAIN_TIMER, no self

local DIRECTIONALS  = require 'infra.dir'
local LONG_WALK     = require 'view.helpers.long_walk'
local ADJACENCY     = require 'view.helpers.adjacency'
local INPUT         = require 'input'
local DEFS          = require 'domain.definitions'
local VIEWDEFS      = require 'view.definitions'
local HandView      = require 'view.gameplay.actionhud.hand'
local Minimap       = require 'view.gameplay.actionhud.minimap'
local EquipmentDock = require 'view.gameplay.actionhud.equipmentdock'
local ConditionDock = require 'view.gameplay.actionhud.conditiondock'
local FocusBar      = require 'view.focusbar'
local HoldBar       = require 'view.helpers.holdbar'
local vec2          = require 'cpml' .vec2
local Util          = require "steaming.util"
local Class         = require "steaming.extra_libs.hump.class"
local ELEMENT       = require "steaming.classes.primitives.element"

local _INFO_LAG = 0.65 -- seconds
local _MARGIN = 20

local ActionHUD = Class{
  __includes = { ELEMENT }
}

-- [[ Constant Variables ]]--

ActionHUD.INTERFACE_COMMANDS = {
  INSPECT_MENU = "INSPECT_MENU",
  SAVE_QUIT = "SAVE_QUIT",
}

--[[ Basic methods ]]--

function ActionHUD:init(route)

  ELEMENT.init(self)

  self.route = route

  local W, _ = VIEWDEFS.VIEWPORT_DIMENSIONS()

  -- Hand view
  self.handview = HandView(route)
  self.handview:register("HUD_BG", nil, "hand_view")

  local margin, off = 20, 20

  -- Wieldable dock
  self.wielddock = EquipmentDock(W/5 - EquipmentDock.getWidth()/2 - margin/2 + off)
  self.wielddock:register("HUD")

  -- Wearable dock
  self.weardock = EquipmentDock(W/5 + EquipmentDock.getWidth()/2 + margin/2 + off)
  self.weardock:register("HUD")

  -- Conditions dock
  self.conddock = ConditionDock(4*W/5, 4)
  self.conddock:register("HUD_BG")

  -- Minimap
  local size = 192
  self.minimap = Minimap(route, W - _MARGIN - size, _MARGIN, size, size)
  self.minimap:register("HUD_BG", nil, "minimap")

  -- HUD state (player turn or not)
  self.player_turn = false

  -- Card info
  self.info_lag = false

  -- Focus bar
  self.focusbar = FocusBar(route, self.handview)
  self.focusbar:register("HUD")

  -- Hold bar
  local w,h = VIEWDEFS.VIEWPORT_DIMENSIONS()
  self.holdbar = HoldBar{'EXTRA'}
  self.holdbar:setPosition(vec2(w,h)/2)
  self.holdbar:lock()
  self.holdbar:register("HUD")
  self.justheld = false

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
  self.wielddock:destroy()
  self.weardock:destroy()
  self.conddock:destroy()
  self.minimap:destroy()
  ELEMENT.destroy(self)
end

function ActionHUD:activateAbility()
  self.handview:keepFocusedCard(true)
end

function ActionHUD:enableTurn(unlock_holdbar)
  self.player_turn = true
  if unlock_holdbar and not self.justheld then
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

function ActionHUD:lockHoldbar()
  self.holdbar:lock()
end

function ActionHUD:unlockHoldbar()
  self.holdbar:unlock()
end

function ActionHUD:getWearDockPosition()
  return self.weardock:getSlotPosition()
end

function ActionHUD:getWieldDockPosition()
  return self.wielddock:getSlotPosition()
end

function ActionHUD:getCondDockPosition(index)
  return self.conddock:getSlotPosition(index)
end

function ActionHUD:getConditionsCount()
  return self.conddock:getConditionsCount()
end

function ActionHUD:findWidgetCard(card)
  if self.weardock:getCard(1) and
     self.weardock:getCard(1).card == card then
    return self.weardock:removeCard(1)
  end
  if self.wielddock:getCard(1) and
     self.wielddock:getCard(1).card == card then
      return self.wielddock:removeCard(1)
  end
  for i = 1, self:getConditionsCount() do
    if self.conddock:getCard(i) and
       self.conddock:getCard(i).card == card then
        return self.conddock:removeCard(i)
    end
  end

  return error("Couldn't find widget")
end

--[[ INPUT methods ]]--

function ActionHUD:wasAnyPressed()
  return INPUT.wasAnyPressed()
end

local _HAND_FOCUS_DIR = { LEFT = true, RIGHT = true }

function ActionHUD:actionRequested()
  local action_request
  local player_focused = self.route.getControlledActor():isFocused()
  local dir = DIRECTIONALS.hasDirectionTriggered()
  if dir then
    if player_focused then
      if _HAND_FOCUS_DIR[dir] then
        self:moveHandFocus(dir)
      end
    else
      if INPUT.isActionDown('ACTION_3') and LONG_WALK.isAllowed(self) then
        LONG_WALK.start(self, dir)
      else
        action_request = {DEFS.ACTION.MOVE, dir}
      end
    end
  end

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
    if player_focused then
      action_request = {DEFS.ACTION.END_FOCUS}
    else
      action_request = {DEFS.ACTION.IDLE}
    end
  elseif INPUT.wasActionPressed('ACTION_2') then
    if not player_focused then
      action_request = {DEFS.ACTION.RECEIVE_PACK}
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
    if action_request[1] ~= DEFS.ACTION.PLAY_CARD then
      self:resetCardInfoLag()
    end
    return unpack(action_request)
  end

  return false
end

--[[ Update ]]--

local function _disableHUDElements(self)
  --self:disableCardInfo()
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
  if not self.justheld and self.holdbar:isLocked() then
    self.holdbar:unlock()
  end
end

function ActionHUD:update(dt)
  --Checks if player can draw a new hand
  local player = self.route.getControlledActor()
  if player:getPP() < player:getBody():getConsumption() and
     not self.holdbar:isLocked()
  then
    self.holdbar:lock()
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
      if INPUT.isActionDown('ACTION_3') then
        self:disableCardInfo()
        if self.handview:isActive() then
          self.handview:deactivate()
        end
        _startInspect(self)
      else
        self:enableCardInfo()
        if not self.handview:isActive() then
          self.handview:activate()
        end
        if self.inspecting then
          _endInspect(self)
        end
      end
    else
      if self.inspecting then
        _endInspect(self)
      end
      self.focusbar:hide()
      _disableHUDElements(self)
    end
  else
    if self.inspecting then
      _endInspect(self)
    end
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
