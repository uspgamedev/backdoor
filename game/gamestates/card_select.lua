--MODULE FOR THE GAMESTATE: SELECTING A CARD IN HAND--

local INPUT = require 'infra.input'
local CONTROL = require 'infra.control'

local state = {}


--LOCAL VARIABLES--

local _route
local _sector_view
local _hand_view

local _task

local _timer_handles = {}

local _hand_size
local _focus_index

local _mapped_signals
local _previous_control_map

local SIGNALS = {
  PRESS_RIGHT = {"move_focus", "right"},
  PRESS_LEFT = {"move_focus", "left"},
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

local function _move_focus(dir)
  if dir == "left" then
    _focus_index = math.max(1, _focus_index - 1)
  elseif dir == "right" then
    _focus_index = math.min(_hand_size, _focus_index + 1)
  end

  _hand_view.focus_index = _focus_index

end

local function _confirm_card()
  local args = {
    chose_a_card = true,
    card_index = _focus_index,
  }
  SWITCHER.pop(args)
end

local function _cancel()
  local args = {
    chose_a_card = false,
  }
  SWITCHER.pop(args)
end

local function _resumeTask(...)
  if _task then
    local _
    _, _task = assert(coroutine.resume(_task, ...))
  end
end

local function _makeSignalHandler(callback)
  return function (...)
    local controlled_actor = _route.getControlledActor()
    if controlled_actor then
      _task = coroutine.create(callback)
      return _resumeTask(...)
    end
  end
end

function _registerSignals()
  Signal.register("move_focus", _makeSignalHandler(_move_focus))
  Signal.register("confirm", _makeSignalHandler(_confirm_card))
  Signal.register("cancel", _makeSignalHandler(_cancel))
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

function state:enter(_, route, sector_view, hand_view)

  _route = route
  _sector_view = sector_view
  _hand_view = hand_view

  _focus_index = 1
  _hand_size = #_hand_view.hand
  _hand_view.focus_index = 1

  if _timer_handles["start"] then
    MAIN_TIMER:cancel(_timer_handles["start"])
  end
  if _timer_handles["end"] then
    MAIN_TIMER:cancel(_timer_handles["end"])
  end
  _timer_handles["start"] = MAIN_TIMER:tween(0.2, _hand_view,
                                             { y = _hand_view.initial_y - 200 },
                                             'out-cubic')

  _registerSignals()

  _previous_control_map = CONTROL.getMap()
  CONTROL.setMap(_mapped_signals)

  --Make cool animation for cards showing up

end

function state:leave()

  _hand_view.focus_index = -1


  if _timer_handles["start"] then
    MAIN_TIMER:cancel(_timer_handles["start"])
  end
  if _timer_handles["end"] then
    MAIN_TIMER:cancel(_timer_handles["end"])
  end
  _timer_handles["end"] = MAIN_TIMER:tween(0.2, _hand_view, {y = _hand_view.initial_y}, 'out-cubic')

  _unregisterSignals()

end

function state:update(dt)

  if not DEBUG then
    INPUT.update()
    MAIN_TIMER:update(dt)
    _sector_view:lookAt(_route.getControlledActor())
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

  if not DEBUG then
    INPUT.key_pressed(key)
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

    if not DEBUG then
        INPUT.key_released(key)
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
