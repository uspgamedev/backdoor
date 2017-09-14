--MODULE FOR THE GAMESTATE: SELECTING A CARD IN HAND--

local CONTROL = require 'infra.control'

local state = {}


--LOCAL VARIABLES--

local _route
local _hand_view

local _task

local _mapped_signals
local _previous_control_map

local SIGNALS = {
  PRESS_RIGHT = {"move_focus", "right"},
  PRESS_LEFT = {"move_focus", "left"},
  PRESS_UP = {"change_action_type", "up"},
  PRESS_DOWN = {"change_action_type", "down"},
  PRESS_CONFIRM = {"confirm"},
  PRESS_CANCEL = {"cancel"},
  PRESS_SPECIAL = {"cancel"},
  PRESS_PAUSE = {"pause"},
  PRESS_QUIT = {"quit"}
}

--LOCAL FUNCTIONS DECLARATIONS
local _unregisterSignals
local _registerSignals

--LOCAL FUNCTIONS--

local function _moveFocus(dir)
  _hand_view:moveFocus(dir)
end

local function _changeActionType(dir)
  _hand_view:changeActionType(dir)
end

local function _confirmCard()
  local args = {
    chose_a_card = true,
    action_type = _hand_view:getActionType(),
    card_index = _hand_view:getFocus(),
  }
  SWITCHER.pop(args)
end

local function _cancel()
  local args = {
    chose_a_card = false,
  }
  SWITCHER.pop(args)
end

function _registerSignals()
  Signal.register("move_focus", _moveFocus)
  Signal.register("change_action_type", _changeActionType)
  Signal.register("confirm", _confirmCard)
  Signal.register("cancel", _cancel)
  CONTROL.setMap(_mapped_signals)
end

function _unregisterSignals()
  for _,signal_pack in pairs(SIGNALS) do
    Signal.clear(signal_pack[1])
  end
  CONTROL.setMap(_previous_control_map)
end

--STATE FUNCTIONS--

function state:init()
  _mapped_signals = {}
  for input_name, signal_pack in pairs(SIGNALS) do
    _mapped_signals[input_name] = function ()
      Signal.emit(unpack(signal_pack))
    end
  end
end

function state:enter(_, route, hand_view)

  _route = route
  _hand_view = hand_view

  _hand_view:activate()

  _registerSignals()

  _previous_control_map = CONTROL.getMap()
  CONTROL.setMap(_mapped_signals)

  --Make cool animation for cards showing up

end

function state:leave()

  _hand_view:deactivate()

  _unregisterSignals()

end

function state:update(dt)

  if not DEBUG then
    MAIN_TIMER:update(dt)
  end

  Util.destroyAll()

end

function state:draw()

    Draw.allTables()

end

function state:keypressed(key)

  imgui.KeyPressed(key)
  if imgui.GetWantCaptureKeyboard() then
     return
  end

  if key ~= "escape" then
      Util.defaultKeyPressed(key)
  end

end

function state:textinput(t)
  imgui.TextInput(t)
end

function state:keyreleased(key)

    imgui.KeyReleased(key)
    if imgui.GetWantCaptureKeyboard() then
       return
    end

end

function state:mousemoved(x, y)
  imgui.MouseMoved(x, y)
end

function state:mousepressed(x, y, button)
  imgui.MousePressed(button)
end

function state:mousereleased(x, y, button)
  imgui.MouseReleased(button)
end

function state:wheelmoved(x, y)
  imgui.WheelMoved(y)
end

--Return state functions
return state
