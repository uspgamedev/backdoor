--MODULE FOR THE GAMESTATE: PLAYER TURN--

local DIR = require 'domain.definitions.dir'
local INPUT = require 'infra.input'
local ACTION = require 'domain.action'
local CONTROL = require 'infra.control'

local state = {}

--LOCAL VARIABLES--

local _task
local _mapped_signals
local _route
local _previous_control_map

local SIGNALS = {
  PRESS_UP = {"move", "up"},
  PRESS_DOWN = {"move", "down"},
  PRESS_RIGHT = {"move", "right"},
  PRESS_LEFT = {"move", "left"},
  PRESS_ACTION_1 = {"widget_1"},
  PRESS_ACTION_2 = {"widget_2"},
  PRESS_ACTION_3 = {"widget_3"},
  PRESS_ACTION_4 = {"widget_4"},
  PRESS_SPECIAL = {"start_card_turn"},
  PRESS_CANCEL = {"wait"},
  PRESS_PAUSE = {"pause"},
  PRESS_QUIT = {"quit"}
}

--LOCAL FUNCTIONS DECLARATIONS--

local _unregisterSignals
local _registerSignals

--LOCAL FUNCTIONS--

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

local function _usePrimaryAction()
  local current_sector = _route.getCurrentSector()
  local controlled_actor = _route.getControlledActor()
  local action_name = controlled_actor:getAction('PRIMARY')
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
        return
      end
    end
  end
  _next_action = {'PRIMARY', params}
end

local function _saveAndQuit()
  _route.saveState()
  SWITCHER.switch(GS.START_MENU)
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
  Signal.register("move", _makeSignalHandler(_moveActor))
  Signal.register("widget_1", _makeSignalHandler(_usePrimaryAction))
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

function state:enter(_, route, sector_view)

  _route = route
  _sector_view = sector_view

  _registerSignals()

  _previous_control_map = CONTROL.getMap()
  CONTROL.setMap(_mapped_signals)

end

function state:leave()

  _unregisterSignals()

end

function state:resume(state, args)
  if state == GS.PICK_TARGET then

    _registerSignals()
    _resumeTask(args)

  end
end

function state:update(dt)

  if not DEBUG then
    INPUT.update()
    _sector_view:lookAt(_route.getControlledActor())

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
