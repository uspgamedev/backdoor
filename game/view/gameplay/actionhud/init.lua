
-- luacheck: globals MAIN_TIMER GS SWITCHER, no self

local DIRECTIONALS    = require 'infra.dir'
local LONG_WALK       = require 'view.helpers.long_walk'
local ADJACENCY       = require 'view.helpers.adjacency'
local INPUT           = require 'input'
local DEFS            = require 'domain.definitions'
local VIEWDEFS        = require 'view.definitions'
local PLAYSFX         = require 'helpers.playsfx'
local HandView        = require 'view.gameplay.actionhud.hand'
local Minimap         = require 'view.gameplay.actionhud.minimap'
local EquipmentDock   = require 'view.gameplay.actionhud.equipmentdock'
local ControlHint     = require 'view.gameplay.actionhud.controlhint'
local ConditionDock   = require 'view.gameplay.actionhud.conditiondock'
local FocusBar        = require 'view.gameplay.actionhud.focusbar'
local TurnPreview     = require 'view.gameplay.actionhud.turnpreview'
local InfoPanel       = require 'view.gameplay.actionhud.infopanel'
local CardView        = require 'view.card'
local Util            = require "steaming.util"
local Class           = require "steaming.extra_libs.hump.class"
local ELEMENT         = require "steaming.classes.primitives.element"

local vec2            = require 'cpml' .vec2

local _MARGIN = 20

local ActionHUD = Class{
  __includes = { ELEMENT }
}

-- [[ Constant Variables ]]--

ActionHUD.INTERFACE_COMMANDS = {
  INSPECT_MENU = "INSPECT_MENU",
  SAVE_QUIT = "SAVE_QUIT",
}

ActionHUD.ID = 'action-hud'

--[[ Basic methods ]]--

function ActionHUD:init(route)

  ELEMENT.init(self)

  self.route = route

  local W, _ = VIEWDEFS.VIEWPORT_DIMENSIONS()

  -- Hand view
  self.handview = HandView(route)
  self.handview:register("HUD_BG", nil, "hand_view")

  local margin, off = 20, 20
  local player = route:getPlayerActor()

  -- Wieldable dock
  self.wielddock = EquipmentDock(W/5 - EquipmentDock.getWidth()/2 - margin/2 + off)
  self.wielddock:updateDockPosition(player:getBody():getEquipmentAt('wieldable'))
  self.wielddock:register("HUD")

  -- Wearable dock
  self.weardock = EquipmentDock(W/5 + EquipmentDock.getWidth()/2 + margin/2 + off)
  self.weardock:updateDockPosition(player:getBody():getEquipmentAt('wearable'))
  self.weardock:register("HUD")

  -- Conditions dock
  self.conddock = ConditionDock(4*W/5 + 15)
  local count = player:getBody():getWidgetCount()
  if player:getBody():getEquipmentAt('wearable') then
    count = count - 1
  end
  if player:getBody():getEquipmentAt('wieldable') then
    count = count - 1
  end
  self.conddock:updateConditionsPositions(count)
  self.conddock:register("HUD_BG")

  self:_loadDocks()

  self.focus_hint = {
    LEFT = {
      [self.handview] = self.weardock,
      [self.weardock] = self.wielddock,
    },
    RIGHT = {
      [self.weardock] = self.handview,
      [self.wielddock] = self.weardock,
    }
  }

  self.current_focus = self.handview

  -- Minimap
  local size = 192
  local preview_margin = 10
  self.minimap = Minimap(route, W - _MARGIN - size, _MARGIN, size, size)
  self.minimap:register("HUD_BG", nil, "minimap")

  -- Turn preview
  self.turnpreview = TurnPreview(route.getPlayerActor(), self.handview,
                                 W - TurnPreview.WIDTH,
                                 _MARGIN + size + preview_margin)
  self.turnpreview:register("HUD_BG_LOWER")

  -- HUD state (player turn or not)
  self.player_turn = false
  self.player_focused = false

  -- Focus bar
  self.focusbar = FocusBar(route, self.handview)
  self.focusbar:register("HUD_MIDDLE")

  -- Long walk variables
  self.alert = false
  self.long_walk = false
  self.adjacency = {}
  ADJACENCY.unset(self.adjacency)

  -- Info Panel
  self.infopanel = InfoPanel(vec2(16, 100), self.handview)
  self.infopanel:register('HUD_MIDDLE')

  -- Control hints
  self.hand_hint = ControlHint(240+13, 28, ControlHint.BUTTON.ACTION_LEFT)
  self.hand_hint:register("HUD_MIDDLE")
  self.open_packs_hint = ControlHint(240+138, 8, ControlHint.BUTTON.ACTION_UP)
  self.open_packs_hint:register("HUD_MIDDLE")
  self.cancel_hint = ControlHint(240+138, 48, ControlHint.BUTTON.ACTION_DOWN)
  self.cancel_hint:register("HUD_MIDDLE")
  self.confirm_hint = ControlHint(240+263, 28, ControlHint.BUTTON.ACTION_RIGHT)
  self.confirm_hint:register("HUD_MIDDLE")
  self.show_stats_hint = ControlHint(13, 8, ControlHint.BUTTON.SHOULDER_RIGHT)
  self.show_stats_hint:register("HUD_MIDDLE")
  self.toggle_hints_hint = ControlHint(13, 48, ControlHint.BUTTON.SHOULDER_LEFT)
  self.toggle_hints_hint:register("HUD_MIDDLE")
end

function ActionHUD:_loadDocks()
  local player = assert(self.route.getPlayerActor())
  for _, widget in player:getBody():eachWidget() do
    local cardview = CardView(widget)
    local dock = self:getDockFor(widget)
    local pos = dock:getAvailableSlotPosition()
    local mode = dock:getCardMode()
    cardview:register('HUD_FX')
    cardview:setMode(mode)
    cardview.position = pos
    dock:addCard(cardview)
  end
end

function ActionHUD:destroy()
  self.handview:destroy()
  self.focusbar:destroy()
  self.wielddock:destroy()
  self.weardock:destroy()
  self.conddock:destroy()
  self.minimap:destroy()
  self.turnpreview:destroy()
  self.hand_hint:destroy()
  self.cancel_hint:destroy()
  self.confirm_hint:destroy()
  self.open_packs_hint:destroy()
  self.show_stats_hint:destroy()
  self.toggle_hints_hint:destroy()
  ELEMENT.destroy(self)
end

function ActionHUD:activateAbility()
  self.handview:keepFocusedCard(true)
end

function ActionHUD:enableTurn()
  self.player_turn = true
end

function ActionHUD:refreshTurnPreview()
  self.turnpreview:refresh()
end

function ActionHUD:disableTurnPreview()
  self.turnpreview:disable()
end

function ActionHUD:disableTurn()
  self.player_turn = false
end

function ActionHUD:getHandView()
  return self.handview
end

function ActionHUD:isHandActive()
  return self.handview:isActive()
end

function ActionHUD.getCurrent()
  return Util.findId(ActionHUD.ID)
end

function ActionHUD:isPlayerFocused()
  return self.player_focused
end

function ActionHUD:moveFocus(dir)
  if self.current_focus:moveFocus(dir) then
    self.infopanel:setTextFromCard(self.current_focus:getFocusedCard().card)
  else
    local next_focused = self.current_focus
    repeat
      next_focused = self.focus_hint[dir][next_focused]
      if next_focused and next_focused:hasCard() then
        self.current_focus:unfocus()
        self.current_focus = next_focused
        next_focused:focus(dir)
        self.infopanel:setTextFromCard(next_focused:getFocusedCard().card)
        break
      end
    until not next_focused
  end
end

function ActionHUD:sendAlert(flag)
  self.alert = self.alert or flag
end

function ActionHUD:getDockFor(card)
  if card:isWidget() then
    if card:isEquipment() then
      local placement = card:getWidgetPlacement()
      if placement == "wieldable" then
        return self.wielddock
      elseif placement == "wearable" then
        return self.weardock
      else
        return error("unknown equipment placement: ".. placement)
      end
    else
      return self.conddock
    end
  end
end

function ActionHUD:getWidgetCard(card)
  if self.weardock:getCard() and
     self.weardock:getCard().card == card then
    return self.weardock:getCard()
  end
  if self.wielddock:getCard() and
     self.wielddock:getCard().card == card then
      return self.wielddock:getCard()
  end
  for i = 1, self.conddock:getConditionsCount() do
    local condition = self.conddock:getCard(i)
    if condition and
       condition.card == card then
        return condition
    end
  end

  return error("Couldn't find widget")
end

function ActionHUD:removeWidgetCard(card)
  if self.weardock:getCard() and
     self.weardock:getCard().card == card then
    PLAYSFX("wearable-unequip")
    return self.weardock:removeCard()
  end
  if self.wielddock:getCard() and
     self.wielddock:getCard().card == card then
      PLAYSFX("wieldable-unequip")
      return self.wielddock:removeCard()
  end
  for i = 1, self.conddock:getConditionsCount() do
    local condition = self.conddock:getCard(i)
    if condition and
       condition.card == card then
         PLAYSFX("condition-unequip")
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
  local player_focused = self.player_focused
  local dir = DIRECTIONALS.hasDirectionTriggered()
  if player_focused then
    if dir and _HAND_FOCUS_DIR[dir] then
      self:moveFocus(dir)
    end
  else
    if LONG_WALK.isAllowed(self) then
      local dir_down = DIRECTIONALS.getDirectionDown()
      if dir_down ~= self.long_walk then
        LONG_WALK.start(self, dir_down)
      else
        self.alert = true
      end
    elseif dir then
      action_request = {DEFS.ACTION.MOVE, dir}
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
      self.player_focused = false
      self.infopanel:hide()
      return
    else
      action_request = {DEFS.ACTION.IDLE}
    end
  elseif INPUT.wasActionPressed('SPECIAL') then
    self.player_focused = not self.player_focused
    if self.player_focused then
      self.infopanel:show()
    else
      self.infopanel:hide()
    end
    return false
  elseif INPUT.wasActionPressed('MENU') then
    if player_focused then
      local card_index = self.handview:getFocus()
      if card_index > 0 then
        action_request = {DEFS.ACTION.DISCARD_CARD, card_index}
      end
    else
      action_request = {DEFS.ACTION.RECEIVE_PACK}
    end
  elseif INPUT.wasActionPressed('PAUSE') then
    if player_focused then
      self.player_focused = false
      return false
    else
      action_request = {ActionHUD.INTERFACE_COMMANDS.SAVE_QUIT}
    end
  elseif INPUT.wasActionPressed('HELP') then
    local control_hints = Util.findSubtype("control_hints")
    if control_hints then
      for button in pairs(control_hints) do
          button:toggleShow()
      end
    end
  end

  -- choose action
  if self.long_walk then
    if not action_request and LONG_WALK.continue(self) then
      action_request = {DEFS.ACTION.MOVE, self.long_walk}
    else
      self.long_walk = false
    end
  end

  if action_request then
    return unpack(action_request)
  end

  return false
end

--[[ Update ]]--

local function _disableHUDElements(self)
  if self.handview:isActive() then
    self.handview:deactivate()
  end
end

function ActionHUD:update(dt)
  self.minimap:update(dt)
  self.turnpreview:update(dt)

  -- Control hints
  local control_hints = Util.findSubtype("control_hints")
  if control_hints then
    local mode
    if SWITCHER.current() == GS.PICK_DIR or
       SWITCHER.current() == GS.PICK_TARGET then
         mode = ControlHint.MODE.TARGET
    elseif self.player_focused then
         mode = ControlHint.MODE.FOCUS
    else
         mode = ControlHint.MODE.DEFAULT
    end
    for button in pairs(control_hints) do
        button:setMode(mode)
    end
  end

  -- Input alerts long walk
  if INPUT.wasAnyPressed(0.5) then
    self.alert = true
  end

  if self.player_turn then
    if self.player_focused then
      if not self.handview:isActive() then
        self.handview:activate()
        self.infopanel:setTextFromCard(self.current_focus:getFocusedCard().card)
      end
    else
      _disableHUDElements(self)
    end
  else
    _disableHUDElements(self)
  end

end

return ActionHUD
