
--- MODULE FOR THE GAMESTATE: PLAYER TURN
--  This gamestate rolls out when the player's turn arrives. It pops the action
--  the player chose to do.

local DEFS          = require 'domain.definitions'
local DIR           = require 'domain.definitions.dir'
local ACTION        = require 'domain.action'
local ABILITY       = require 'domain.ability'
local DIRECTIONALS  = require 'infra.dir'
local INPUT         = require 'input'

local state = {}

--[[ Local Variables ]]--

local _task
local _route
local _next_action
local _view
local _extended_hud

local _save_and_quit

local _ACTION = {}

--[[ Task Functions ]]--

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

--[[ HUD Functions ]]--

local function _showHUD()
  _view.actor:show()
end

local function _hideHUD()
  _view.actor:hide()
end

--[[ State Methods ]]--

function state:enter(_, route, view)

  _route = route
  _save_and_quit = false

  _view = view
  _view.hand:reset()

end

function state:resume(from, args)
  _resumeTask(args)
  if from == GS.ACTION_MENU and args.action then
    _startTask(args.action)
  end
end

function state:update(dt)

  if DEBUG then
    return SWITCHER.push(GS.DEVMODE)
  end

  if _save_and_quit then return SWITCHER.pop("SAVE_AND_QUIT") end

  _view.sector:lookAt(_route.getControlledActor())

  MAIN_TIMER:update(dt)

  if INPUT.isActionDown("ACTION_4") and not _extended_hud then
    _extended_hud = true
    _showHUD()
  elseif _extended_hud and not INPUT.isActionDown("ACTION_4") then
    _extended_hud = false
    _hideHUD()
  end

  if _extended_hud then
    if DIRECTIONALS.wasDirectionTriggered('UP') then
      _view.widget:scrollUp()
    elseif DIRECTIONALS.wasDirectionTriggered('DOWN') then
      _view.widget:scrollDown()
    end
  else
    for _,dir in ipairs(DIR) do
      if DIRECTIONALS.wasDirectionTriggered(dir) then
        return _startTask(DEFS.ACTION.MOVE, dir)
      end
    end

    if INPUT.wasActionPressed('CONFIRM') then
      _startTask(DEFS.ACTION.INTERACT)
    elseif INPUT.wasActionPressed('CANCEL') then
      _startTask(DEFS.ACTION.IDLE)
    elseif INPUT.wasActionPressed('SPECIAL') then
      _startTask(DEFS.ACTION.USE_SIGNATURE)
    elseif INPUT.wasActionPressed('ACTION_1') then
      if _route.getControlledActor():isHandEmpty() then
        _startTask(DEFS.ACTION.DRAW_NEW_HAND)
      else
        _startTask(DEFS.ACTION.PLAY_CARD)
      end
    elseif INPUT.wasActionPressed('ACTION_2') then
      _startTask(DEFS.ACTION.ACTIVATE_WIDGET)
    elseif INPUT.wasActionPressed('ACTION_3') then
      _startTask(DEFS.ACTION.RECEIVE_PACK)
    elseif INPUT.wasActionPressed('EXTRA') then
      return SWITCHER.push(GS.ACTION_MENU, _route)
    elseif INPUT.wasActionPressed('PAUSE') then
      _save_and_quit = true
      return
    end
  end

  if _next_action then
    SWITCHER.pop({next_action = _next_action})
    _next_action = nil
  end

  Util.destroyAll()

end

function state:draw()
  Draw.allTables()
end

function state:keypressed(key)
  if key == 'f1' then DEBUG = true end
end

--[[ Action functions ]]--

local function _useAction(action_slot, params)
  if not ACTION.exists(action_slot) then return false end
  local current_sector = _route.getCurrentSector()
  local controlled_actor = _route.getControlledActor()
  params = params or {}
  local param = ACTION.pendingParam(action_slot, controlled_actor, params)
  while param do
    if param.typename == 'choose_dir' then
      SWITCHER.push(GS.PICK_DIR, _view.sector, param['body-block'])
      local dir = coroutine.yield(_task)
      if dir then
        params[param.output] = dir
      else
        return false
      end
    elseif param.typename == 'choose_target' then
      SWITCHER.push(
        GS.PICK_TARGET, _view.sector,
        {
          pos = { controlled_actor:getPos() },
          aoe_hint = param['aoe-hint'],
          range_checker = function(i, j)
            return ABILITY.param('choose_target')
                          .isWithinRange(controlled_actor, param, {i,j})
          end,
          validator = function(i, j)
            return ABILITY.validate('choose_target', controlled_actor, param,
                                    {i,j})
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
      SWITCHER.push(
        GS.PICK_WIDGET_SLOT, controlled_actor,
        function (which_slot)
          return ABILITY.validate('choose_widget_slot', controlled_actor, param,
                                  which_slot)
        end
      )
      local args = coroutine.yield(_task)
      if args.picked_slot then
        params[param.output] = args.picked_slot
      else
        return false
      end
    end
    param = ACTION.pendingParam(action_slot, controlled_actor, params)
  end
  _next_action = {action_slot, params}
  return true
end

_ACTION[DEFS.ACTION.MOVE] = function (dir)
  local current_sector = _route.getCurrentSector()
  local controlled_actor = _route.getControlledActor()
  local i, j = controlled_actor:getPos()

  dir = DIR[dir]
  i, j = i+dir[1], j+dir[2]
  if current_sector:isValid(i,j) then
    _useAction(DEFS.ACTION.MOVE, { pos = {i,j} })
  end
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
  _useAction(DEFS.ACTION.DRAW_NEW_HAND)
end

_ACTION[DEFS.ACTION.PLAY_CARD] = function()
  if #_view.hand.hand > 0 then
    SWITCHER.push(GS.CARD_SELECT, _route, _view)
    local args = coroutine.yield(_task)
    if args.chose_a_card then
      if args.action_type == 'play' then
        if _useAction(DEFS.ACTION.PLAY_CARD,
                      { card_index = args.card_index }) then
          Signal.emit("actor_used_card", _route.getControlledActor(), index)
        end
      end
    end
  end
end

_ACTION[DEFS.ACTION.CONSUME_CARDS] = function()
  SWITCHER.push(GS.MANAGE_BUFFER, _route.getControlledActor())
  local args = coroutine.yield(_task)
  _useAction(DEFS.ACTION.CONSUME_CARDS, { consumed = args.consumed })
end

_ACTION[DEFS.ACTION.RECEIVE_PACK] = function()
  SWITCHER.push(GS.OPEN_PACK, _route.getControlledActor():getNextPrizePack())
  local args = coroutine.yield(_task)
  _useAction(DEFS.ACTION.RECEIVE_PACK,
             { consumed = args.consumed, pack = args.pack })
end

_ACTION[DEFS.ACTION.IDLE] = function()
  _useAction(DEFS.ACTION.IDLE)
end

return state

