--MODULE FOR THE GAMESTATE: PLAYER TURN--

local DIR = require 'domain.definitions.dir'
local ACTION = require 'domain.action'
local CONTROL = require 'infra.control'

local HandView = require 'domain.view.handview'

local state = {}

--LOCAL VARIABLES--

local _task
local _mapped_signals
local _route
local _next_action
local _hand_view

local _previous_control_map
local _save_and_quit
local _exit_sector


local SIGNALS = {
  PRESS_UP = {"move", "up"},
  PRESS_DOWN = {"move", "down"},
  PRESS_RIGHT = {"move", "right"},
  PRESS_LEFT = {"move", "left"},
  PRESS_CONFIRM = {"confirm"},
  PRESS_CANCEL = {"wait"},
  PRESS_SPECIAL = {"start_card_selection"},
  PRESS_EXTRA = {"extra"},
  PRESS_ACTION_1 = {"widget_1"},
  PRESS_ACTION_2 = {"widget_2"},
  PRESS_ACTION_3 = {"widget_3"},
  PRESS_ACTION_4 = {"widget_4"},
  PRESS_PAUSE = {"pause"},
  PRESS_QUIT = {"quit"}
}

--LOCAL FUNCTIONS DECLARATIONS--

local _unregisterSignals
local _registerSignals

--LOCAL FUNCTIONS--

local function _changeToCardSelectScreen()

  if #_hand_view.hand > 0 then
    _unregisterSignals()
    SWITCHER.push(GS.CARD_SELECT, _route, _sector_view, _hand_view)
  end

end

local function _moveActor(dir)
  local current_sector = _route.getCurrentSector()
  local controlled_actor = _route.getControlledActor()
  local i, j = controlled_actor:getPos()
  dir = DIR[dir]
  i, j = i+dir[1], j+dir[2]
  if current_sector:isValid(i,j) then
    _next_action = {'MOVE', { pos = {i,j} }}
  end
end

local function _useAction(action_slot)
  local current_sector = _route.getCurrentSector()
  local controlled_actor = _route.getControlledActor()
  local action_name = controlled_actor:getAction(action_slot)
  if not action_name then return false end
  local params = {}
  for _,param in ACTION.paramsOf(action_name) do
    if param.typename == 'choose_target' then
      _unregisterSignals()
      SWITCHER.push(
        GS.PICK_TARGET, _sector_view,
        {
          pos = { controlled_actor:getPos() },
          valid_position_func = function(i, j)
            return current_sector:isInside(i,j) and
                   current_sector:getBodyAt(i,j)
          end
        }
      )
      local args = coroutine.yield(_task)
      if args.target_is_valid then
        params[param.output] = current_sector:getBodyAt(unpack(args.pos))
      else
        return false
      end
    end
  end
  _next_action = {action_slot, params}
  return true
end

local function _usePrimaryAction()
  return _useAction('PRIMARY')
end

local function _useFirstWidget()
  return _useAction('WIDGET_A')
end

local function _useSecondWidget()
  return _useAction('WIDGET_B')
end

local function _useThirdWidget()
  return _useAction('WIDGET_C')
end

--- Receive a card index from player hands (between 1 and max-hand-size)
local function _useCardByIndex(index)
  local card = _hand_view.hand[index]
  local player = _route.getControlledActor()

  if _useAction(index) then
    Signal.emit("actor_used_card", player, index)
  end
end

local function _exitSector()
  _exit_sector = true
end

local function _saveAndQuit()
  _save_and_quit = true
end

local function _resumeTask(...)
  if _task then
    local _
    _, _task = assert(coroutine.resume(_task, ...))
  end
end

local function _startTask(callback, ...)
  local controlled_actor = _route.getControlledActor()
  if controlled_actor then
    _task = coroutine.create(callback)
    return _resumeTask(...)
  end
end

local function _makeSignalHandler(callback)
  return function (...)
    return _startTask(callback, ...)
  end
end

function _registerSignals()
  Signal.register("move", _makeSignalHandler(_moveActor))
  Signal.register("confirm", _makeSignalHandler(_exitSector))
  Signal.register("start_card_selection",
                  _makeSignalHandler(_changeToCardSelectScreen))
  Signal.register("widget_1", _makeSignalHandler(_usePrimaryAction))
  Signal.register("widget_2", _makeSignalHandler(_useFirstWidget))
  Signal.register("widget_3", _makeSignalHandler(_useSecondWidget))
  Signal.register("widget_4", _makeSignalHandler(_useThirdWidget))
  Signal.register("pause", _makeSignalHandler(_saveAndQuit))
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
  _save_and_quit = false
  _exit_sector = false

  _hand_view = hand_view
  _hand_view:reset()

  _registerSignals()

  _previous_control_map = CONTROL.getMap()
  CONTROL.setMap(_mapped_signals)

end

function state:leave()

  _unregisterSignals()

end

function state:resume(state, args)
  _registerSignals()
  if state == GS.PICK_TARGET then

    _resumeTask(args)

  elseif state == GS.CARD_SELECT then

    if args.chose_a_card then
      _startTask(_useCardByIndex, args.card_index)
    end

  end
end

function state:update(dt)

  if not DEBUG then
    if _save_and_quit then return SWITCHER.pop("SAVE_AND_QUIT") end
    if _exit_sector then return SWITCHER.pop("EXIT_SECTOR") end
    _sector_view:lookAt(_route.getControlledActor())
    MAIN_TIMER:update(dt)
    if _next_action then
      SWITCHER.pop({next_action = _next_action})
      _next_action = nil
    end

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
