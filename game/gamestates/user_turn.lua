
--- MODULE FOR THE GAMESTATE: PLAYER TURN
--  This gamestate rolls out when the player's turn arrives. It pops the action
--  the player chose to do.

local DEFS          = require 'domain.definitions'
local DIR           = require 'domain.definitions.dir'
local ACTION        = require 'domain.action'
local ABILITY       = require 'domain.ability'
local CONTROL       = require 'infra.control'
local INPUT         = require 'infra.input'

local state = {}

--LOCAL VARIABLES--

local _task
local _mapped_signals
local _route
local _next_action
local _view

local _status_hud
local _previous_control_map
local _save_and_quit
local _exit_sector
local _lock

local _ACTION = {}

local SIGNALS = {
  PRESS_CONFIRM = {"interact"},
  PRESS_CANCEL = {"wait"},
  PRESS_SPECIAL = {"primary"},
  PRESS_EXTRA = {"open_action_menu"},
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
end

local function _unlockState()
  _lock = false
  _registerSignals()
end

local function _showHUD()
  _view.actor:show()
end

local function _hideHUD()
  _view.actor:hide()
end

local function _openActionMenu()

  _lockState()
  SWITCHER.push(GS.ACTION_MENU, _route)

end

local function _useAction(action_slot, params)
  if not ACTION.exists(action_slot) then return false end
  local current_sector = _route.getCurrentSector()
  local controlled_actor = _route.getControlledActor()
  params = params or {}
  local param = ACTION.pendingParam(action_slot, controlled_actor,
                                    current_sector, params)
  while param do
    print("pending param", param.output, param.typename)
    if param.typename == 'choose_target' then
      _lockState()
      SWITCHER.push(
        GS.PICK_TARGET, _view.sector,
        {
          pos = { controlled_actor:getPos() },
          range_checker = function(i, j)
            return ABILITY.param('choose_target')
                          .isWithinRange(current_sector, controlled_actor,
                                        param, {i,j})
          end,
          validator = function(i, j)
            return ABILITY.validate('choose_target', current_sector,
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
    elseif param.typename == "choose_widget_slot" then
      _lockState()
      SWITCHER.push(
        GS.PICK_WIDGET_SLOT, controlled_actor,
        function (which_slot)
          return ABILITY.validate('choose_widget_slot', current_sector,
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
    param = ACTION.pendingParam(action_slot, controlled_actor,
                                current_sector, params)
  end
  _next_action = {action_slot, params}
  return true
end

_ACTION[DEFS.ACTION.INTERACT] = function()
  _useAction(DEFS.ACTION.INTERACT)
end

_ACTION[DEFS.ACTION.USE_SIGNATURE] = function()
  _useAction(DEFS.ACTION.USE_SIGNATURE)
end

_ACTION[DEFS.ACTION.ACTIVATE_WIDGET] = function()
  _useAction(DEFS.ACTION.ACTIVATE_WIDGET)
end

_ACTION[DEFS.ACTION.DRAW_NEW_HAND] = function()
  if _route.getControlledActor():isHandEmpty() then
    _useAction(DEFS.ACTION.DRAW_NEW_HAND)
  end
end

_ACTION[DEFS.ACTION.PLAY_CARD] = function()

  if #_view.hand.hand > 0 then
    _lockState()

    SWITCHER.push(GS.CARD_SELECT, _route, _view.hand)
    local args = coroutine.yield(_task)

    if args.chose_a_card then
      if args.action_type == 'use' then
        if _useAction(DEFS.ACTION.PLAY_CARD,
                      { card_index = args.card_index }) then
          Signal.emit("actor_used_card", _route.getControlledActor(), index)
        end
      elseif args.action_type == 'stash' then
        _useAction(DEFS.ACTION.STASH_CARD, { card_index = args.card_index })
      end
    end
  end

end

_ACTION[DEFS.ACTION.CONSUME_CARDS] = function()
  _lockState()
  SWITCHER.push(GS.MANAGE_BUFFER, _route.getControlledActor())
  local args = coroutine.yield(_task)
  _useAction(DEFS.ACTION.CONSUME_CARDS, { consumed = args.consumed })
end

_ACTION[DEFS.ACTION.RECEIVE_PACK] = function()
  local controlled_actor = _route.getControlledActor()
  if not controlled_actor:hasOpenPack() then
    _lockState()
    SWITCHER.push(GS.OPEN_PACK, controlled_actor)
    local args = coroutine.yield(_task)
    _useAction(DEFS.ACTION.RECEIVE_PACK,
               { consumed = args.consumed, pack = args.pack })
  end
end

_ACTION[DEFS.ACTION.IDLE] = function()
  _useAction(DEFS.ACTION.IDLE)
end

local function _move(dir)
  local current_sector = _route.getCurrentSector()
  local controlled_actor = _route.getControlledActor()
  local i, j = controlled_actor:getPos()

  dir = DIR[dir]
  i, j = i+dir[1], j+dir[2]
  if current_sector:isValid(i,j) then
    _useAction(DEFS.ACTION.MOVE, { pos = {i,j} })
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

local function _startTask(action, ...)
  local controlled_actor = _route.getControlledActor()
  local callback = _ACTION[action]
  if controlled_actor and not _next_action then
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
  Signal.register("open_action_menu", _openActionMenu)
  Signal.register("primary", _makeSignalHandler(_usePrimaryAction))
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
  _resumeTask(args)
  if from == GS.ACTION_MENU and args.action then
    _startTask(args.action)
  end
end

function state:update(dt)

  if not DEBUG and not _lock then
    if _save_and_quit then return SWITCHER.pop("SAVE_AND_QUIT") end
    if _exit_sector then return SWITCHER.pop("EXIT_SECTOR") end

    _view.sector:lookAt(_route.getControlledActor())

    MAIN_TIMER:update(dt)

    if _status_hud and not INPUT.isDown("ACTION_4") then
      _status_hud = false
      _hideHUD()
    elseif not _statusHUD and INPUT.isDown("ACTION_4") then
      _status_hud = true
      _showHUD()
    end

    for _,dir in ipairs(DIR) do
      if INPUT.actionPressed(dir:upper()) then
        return _move(dir)
      end
    end

    if INPUT.actionPressed('CONFIRM') then
      return _startTask(DEFS.ACTION.INTERACT)
    elseif INPUT.actionPressed('CANCEL') then
      return _startTask(DEFS.ACTION.IDLE)
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

