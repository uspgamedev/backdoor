
--- GAMESTATE: Choosing an action

local CONTROL         = require 'infra.control'
local ActionMenuView  = require 'view.actionmenu'

local state = {}

--[[ LOCAL VARIABLES ]]--

local _menu_view
local _last_focus

local _mapped_signals
local _previous_control_map

local SIGNALS = {
  PRESS_UP = {"move_focus", "up"},
  PRESS_DOWN = {"move_focus", "down"},
  PRESS_CONFIRM = {"confirm"},
  PRESS_CANCEL = {"cancel"},
  PRESS_EXTRA = {"cancel"},
}

--[[ LOCAL FUNCTIONS DECLARATIONS ]]--

local _unregisterSignals
local _registerSignals

--[[ LOCAL FUNCTIONS ]]--

local function _moveFocus(dir)
  _menu_view:moveFocus(dir)
end

local function _confirm()
  _last_focus = _menu_view:getCurrentFocus()
  _menu_view:close()
  SWITCHER.pop({ action = _menu_view:getSelected() })
end

local function _cancel()
  _last_focus = _menu_view:getCurrentFocus()
  _menu_view:close()
  SWITCHER.pop({})
end

function _registerSignals()
  Signal.register("move_focus", _moveFocus)
  Signal.register("confirm", _confirm)
  Signal.register("cancel", _cancel)
  _previous_control_map = CONTROL.getMap()
  CONTROL.setMap(_mapped_signals)
end

function _unregisterSignals()
  for _,signal_pack in pairs(SIGNALS) do
    Signal.clear(signal_pack[1])
  end
  CONTROL.setMap(_previous_control_map)
end

--[[ STATE FUNCTIONS ]]--

function state:init()
  _mapped_signals = {}
  for input_name, signal_pack in pairs(SIGNALS) do
    _mapped_signals[input_name] = function ()
      Signal.emit(unpack(signal_pack))
    end
  end
end

function state:enter(_, route)

  local player = route.getControlledActor()
  local action = 'drawhand'
  if player:getHandSize() > 0 then action = 'playcard' end
  _menu_view = ActionMenuView()
  _menu_view:addElement('HUD')
  _menu_view:setCardAction(action)
  _menu_view:open(_last_focus)
  _registerSignals()

end

function state:leave()

  _unregisterSignals()

end

function state:update(dt)

  if not DEBUG then
    MAIN_TIMER:update(dt)
  end

end

function state:draw()

  Draw.allTables()

end

return state

