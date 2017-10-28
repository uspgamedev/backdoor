--MODULE FOR THE GAMESTATE: PLAYER TURN--

local DEFS          = require 'domain.definitions'
local DIR           = require 'domain.definitions.dir'
local ACTION        = require 'domain.action'
local ABILITY       = require 'domain.ability'
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

local _status_hud
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

local function _openActionMenu()

  _unregisterSignals()
  SWITCHER.push(GS.ACTION_MENU, _route)

end

local function _changeToCardSelectScreen()

  if #_view.hand.hand > 0 then
    _unregisterSignals()
    SWITCHER.push(GS.CARD_SELECT, _route, _view.hand)
  end

end

local function _move(dir)
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
  local ability
  if controlled_actor:isCard(action_slot) then
    local card = controlled_actor:getCard(action_slot)
    if card:isArt() then
      ability = card:getArtAbility()
    end
  elseif controlled_actor:isWidget(action_slot) then
    ability = actor:getWidget(action_slot):getWidgetAbility()
  end
  if not ability then
    local action_name = controlled_actor:getAction(action_slot)
    ability = ACTION.ability(action_name)
  end
  if not ability then return false end
  local params = {}
  for _,param in ABILITY.paramsOf(ability) do
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

local function _showHUD()
  _view.actor:show()
end

local function _hideHUD()
  _view.actor:hide()
end

local function _manageBuffer()
  local controlled_actor = _route.getControlledActor()
  _lockState()
  SWITCHER.push(GS.MANAGE_BUFFER, controlled_actor)
end

local function _useWidget()
  local controlled_actor = _route.getControlledActor()
  _lockState()
  SWITCHER.push(
    GS.PICK_WIDGET_SLOT, controlled_actor,
    function (which_slot)
      return not not controlled_actor:getAction(DEFS.WIDGETS[which_slot])
    end
  )
  local args = coroutine.yield(_task)
  if args.picked_slot then
    _useAction(args.picked_slot)
  end
end

local function _interact()
  if not _next_action then
    _next_action = { 'INTERACT' }
  end
end

local function _newHand()
  if _route.getControlledActor():isHandEmpty() then
    _useAction('DRAW_NEW_HAND')
  end
end

local function _openPack()
  local controlled_actor = _route.getControlledActor()
  if not controlled_actor:hasOpenPack() then
    _unregisterSignals()
    SWITCHER.push(GS.OPEN_PACK, controlled_actor)
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
  Signal.register("interact", _makeSignalHandler(_interact))
  Signal.register("drawhand", _makeSignalHandler(_newHand))
  Signal.register("open_action_menu",
                  _makeSignalHandler(_openActionMenu))
  Signal.register("playcard",
                  _makeSignalHandler(_changeToCardSelectScreen))
  Signal.register("primary", _makeSignalHandler(_usePrimaryAction))
  Signal.register("widget", _makeSignalHandler(_useWidget))
  Signal.register("managebuffer", _makeSignalHandler(_manageBuffer))
  Signal.register("openpack", _openPack)
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
    [GS.PICK_WIDGET_SLOT] = true,
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
      elseif args.action_type == 'stash' then
        _next_action = {
          "STASH_CARD", { card_index = args.card_index }
        }
      end
    end

  elseif from == GS.OPEN_PACK then
    _next_action = {
      'RECEIVE_PACK', { consumed = args.consumed, pack = args.pack }
    }
  elseif from == GS.ACTION_MENU and args.action then
    Signal.emit(args.action)
  elseif from == GS.MANAGE_BUFFER then
    _next_action = {
      'CONSUME_CARDS_FROM_BUFFER', { consumed = args.consumed }
    }
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
