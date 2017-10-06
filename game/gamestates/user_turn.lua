--MODULE FOR THE GAMESTATE: PLAYER TURN--

local DIR           = require 'domain.definitions.dir'
local ACTION        = require 'domain.action'
local CONTROL       = require 'infra.control'
local INPUT         = require 'infra.input'

local Queue         = require 'lux.common.Queue'
local HandView      = require 'view.hand'

local state = {}

--LOCAL VARIABLES--

local _task
local _mapped_signals
local _route
local _next_action
local _action_queue
local _view

local _previous_control_map
local _save_and_quit
local _exit_sector
local _lock

local PARAMETER_STATES

local SIGNALS = {
  PRESS_UP = {"move", "up"},
  PRESS_UPLEFT = {"move", "upleft"},
  PRESS_UPRIGHT = {"move", "upright"},
  PRESS_DOWN = {"move", "down"},
  PRESS_DOWNLEFT = {"move", "downleft"},
  PRESS_DOWNRIGHT = {"move", "downright"},
  PRESS_RIGHT = {"move", "right"},
  PRESS_LEFT = {"move", "left"},
  PRESS_CONFIRM = {"confirm"},
  PRESS_CANCEL = {"wait"},
  PRESS_SPECIAL = {"start_card_selection"},
  PRESS_EXTRA = {"extra"},
  PRESS_ACTION_1 = {"primary_action"},
  PRESS_ACTION_3 = {"open_pack"},
  PRESS_PAUSE = {"pause"},
  PRESS_QUIT = {"quit"}
}

--LOCAL FUNCTIONS DECLARATIONS--

local _unregisterSignals
local _registerSignals

--LOCAL FUNCTIONS--

local function _lockState()
  _lock = true
  _unregisterSignals()
  _view.widget:hide()
end

local function _unlockState()
  _lock = false
  _registerSignals()
end

local function _showWidgets()
  return not _next_action and INPUT.isDown('ACTION_2')
end

local function _changeToCardSelectScreen()

  if #_view.hand.hand > 0 then
    _unregisterSignals()
    SWITCHER.push(GS.CARD_SELECT, _route, _view.hand)
  end

end

local function _move(dir)
  if _showWidgets() then
    for i,d in ipairs(DIR) do
      if d == dir then
        _view.widget:select(i)
        break
      end
    end
  else
    local current_sector = _route.getCurrentSector()
    local controlled_actor = _route.getControlledActor()
    local i, j = controlled_actor:getPos()

    dir = DIR[dir]
    i, j = i+dir[1], j+dir[2]
    if current_sector:isValid(i,j) then
      _next_action = {'MOVE', { pos = {i,j} }}
    end
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
      _lockState()
      SWITCHER.push(
        GS.PICK_TARGET, _view.sector,
        {
          pos = { controlled_actor:getPos() },
          range_checker = function(i, j)
            return ACTION.param('choose_target')
                         .isWithinRange(current_sector, controlled_actor,
                                        param, {i,j})
          end,
          validator = function(i, j)
            return ACTION.validate('choose_target', current_sector,
                                   controlled_actor, param, {i,j})
          end
        }
      )
      local args = coroutine.yield(_task)
      if args.target_is_valid then
        params[param.output] = args.pos
      else
        return false
      end
    elseif param.typename == 'choose_buffer' then
      _lockState()
      SWITCHER.push(
        GS.PICK_BUFFER, _route.getControlledActor(),
        function (which_buffer)
          return ACTION.validate('choose_buffer', current_sector,
                                 controlled_actor, param, which_buffer)
        end
      )
      local args = coroutine.yield(_task)
      if args.picked_buffer then
        params[param.output] = args.picked_buffer
      else
        return false
      end
    elseif param.typename == "choose_widget_slot" then
      _lockState()
      SWITCHER.push(
        GS.PICK_WIDGET_SLOT, controlled_actor,
        function (which_slot)
          return ACTION.validate('choose_widget_slot', current_sector,
                                 controlled_actor, param, which_slot)
        end
      )
      local args = coroutine.yield(_task)
      if args.picked_slot then
        params[param.output] = args.picked_slot
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

--- Receive a card index from player hands (between 1 and max-hand-size)
local function _useCardByIndex(index, action_type)
  local player = _route.getControlledActor()

  if _useAction(index) then
    Signal.emit("actor_used_card", player, index)
  end
end

local function _interact()
  if _showWidgets() then
    local selected = _view.widget:getSelected()
    if selected then
      local widget = { 'A', 'B', 'C', 'D' }
      _useAction(('WIDGET_%s'):format(widget[selected]))
    end
  elseif not _next_action then
    _next_action = { 'INTERACT' }
  end
end

local function _newHand()
  if _route.getControlledActor():isHandEmpty() then
    _useAction('NEW_HAND')
  end
end

local function _openPack()
  local controlled_actor = _route.getControlledActor()
  if not controlled_actor:hasOpenPack() then
    _unregisterSignals()
    SWITCHER.push(GS.OPEN_PACK, _route)
  end
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
  Signal.register("move", _move)
  Signal.register("confirm", _makeSignalHandler(_interact))
  Signal.register("extra", _makeSignalHandler(_newHand))
  Signal.register("start_card_selection",
                  _makeSignalHandler(_changeToCardSelectScreen))
  Signal.register("primary_action", _makeSignalHandler(_usePrimaryAction))
  Signal.register("open_pack", _openPack)
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

  PARAMETER_STATES = {
    [GS.PICK_TARGET] = true,
    [GS.PICK_BUFFER] = true,
  }

  _action_queue = Queue(32)

end

function state:enter(_, route, view)

  _route = route
  _save_and_quit = false
  _exit_sector = false

  _view = view
  _view.hand:reset()

  _registerSignals()

  _previous_control_map = CONTROL.getMap()
  CONTROL.setMap(_mapped_signals)

  _unlockState()

end

function state:leave()

  _lockState()

end

function state:resume(from, args)
  _unlockState()
  if PARAMETER_STATES[from] then

    _resumeTask(args)

  elseif from == GS.CARD_SELECT then

    if args.chose_a_card then
      if args.action_type == 'use' then
        _startTask(_useCardByIndex, args.card_index, args.action_type)
      elseif args.action_type == 'remember' then
        _next_action = { "RECALL_CARD", { card_index = args.card_index } }
      elseif args.action_type == 'consume' then
        _next_action = { "CONSUME_CARD", { card_index = args.card_index } }
      end
    end

  elseif from == GS.OPEN_PACK then
    for _,pick in ipairs(args) do
      local t
      if pick.action_type == 'get' then
        t = 'GET_PACK_CARD'
      elseif pick.action_type == 'consume' then
        t = 'CONSUME_PACK_CARD'
      end
      assert(t)
      _action_queue.push({ t, { index = pick.card_index,
                                buffer = pick.buffer_index } })
    end
  end
end

function state:update(dt)

  if not DEBUG and not _lock then
    if _save_and_quit then return SWITCHER.pop("SAVE_AND_QUIT") end
    if _exit_sector then return SWITCHER.pop("EXIT_SECTOR") end

    _view.sector:lookAt(_route.getControlledActor())

    MAIN_TIMER:update(dt)

    if _showWidgets() then
      _view.widget:show()
    else
      _view.widget:hide()
    end

    if not _next_action and not _action_queue.isEmpty() then
      _next_action = _action_queue.pop()
    end

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

