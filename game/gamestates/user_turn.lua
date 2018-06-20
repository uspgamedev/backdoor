
--- MODULE FOR THE GAMESTATE: PLAYER TURN
--  This gamestate rolls out when the player's turn arrives. It pops the action
--  the player chose to do.

local DEFS          = require 'domain.definitions'
local DIR           = require 'domain.definitions.dir'
local SCHEMATICS    = require 'domain.definitions.schematics'
local ACTION        = require 'domain.action'
local ABILITY       = require 'domain.ability'
local MANEUVERS     = require 'lux.pack' 'domain.maneuver'
local DIRECTIONALS  = require 'infra.dir'
local INPUT         = require 'input'
local PLAYSFX       = require 'helpers.playsfx'

local state = {}

-- [[ Constant Variables ]]--
local _OPEN_MENU = "OPEN_MENU"
local _SAVE_QUIT = "SAVE_QUIT"

--[[ Local Variables ]]--

local _task
local _route
local _next_action
local _view

local _widget_abilities = {}
local _long_walk
local _adjacency = {}
local _alert
local _save_and_quit
local _was_on_menu

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

--[[ Adjacency function ]]--

local function _updateAdjacency(dir)
  local i, j = _route.getControlledActor():getPos()
  local sector = _route.getCurrentSector()
  local changed = false
  local side1, side2
  if dir[1] ~= 0 and dir[2] ~= 0 then
    side1 = {0, dir[2]}
    side2 = {dir[1], 0}
  elseif dir[1] == 0 then
    side1 = {-1, dir[2]}
    side2 = { 1, dir[2]}
  elseif dir[2] == 0 then
    side1 = {dir[1], -1}
    side2 = {dir[1],  1}
  end
  local range = {dir, side1, side2}

  for idx, adj_move in ipairs(range) do
    local ti = adj_move[1] + i
    local tj = adj_move[2] + j
    local tile = sector:isInside(ti, tj) and sector:getTile(ti, tj)
    local tile_type = tile and tile.type
    local current = _adjacency[idx]
    _adjacency[idx] = tile_type
    if current ~= -1 then
      if tile_type ~= current then
        changed = true
      end
    end
  end

  return changed
end

local function _unsetAdjacency()
  _adjacency_changes = 0
  for i = 1, 3 do
    _adjacency[i] = -1
  end
end

--[[ Long walk functionf ]]--

local function _canLongWalk()
  local hostile_bodies = _route.getControlledActor():getHostileBodies()
  return (not _long_walk) and #hostile_bodies == 0
end

local function _startLongWalk(dir)
  _unsetAdjacency()
  _long_walk = dir
  _alert = false
end

local function _continueLongWalk()
  local dir = _long_walk
  dir = DIR[dir]
  local i, j = _route.getControlledActor():getPos()
  i, j = i+dir[1], j+dir[2]
  if not _route.getCurrentSector():isValid(i,j) then
    return false
  end
  if _alert then
    _alert = false
    return false
  end

  local hostile_bodies = _route.getControlledActor():getHostileBodies()
  if #hostile_bodies > 0 or _updateAdjacency(dir) then
    return false
  end

  return true
end

--[[ State Methods ]]--

function state:init()
  _long_walk = false
  return _unsetAdjacency()
end

function state:enter(_, route, view, alert)

  _route = route
  _save_and_quit = false
  _alert = alert

  _view = view
  _view.hand:reset()

  _was_on_menu = false

end

function state:resume(from, args)
  _view.sector.setCooldownPreview(0)
  _resumeTask(args)
  if from == GS.ACTION_MENU and args.action then
    _was_on_menu = true
    _startTask(args.action)
  else
  if INPUT.wasAnyPressed() then
    _alert = true
  end

    _was_on_menu = false
  end
end

function state:update(dt)

  if DEBUG then
    return SWITCHER.push(GS.DEVMODE)
  end

  MAIN_TIMER:update(dt)

  if _save_and_quit then return SWITCHER.pop("SAVE_AND_QUIT") end

  _view.sector:lookAt(_route.getControlledActor())

  if INPUT.wasAnyPressed() then
    _alert = true
  end

  if _next_action then
    SWITCHER.pop({next_action = _next_action})
    _next_action = nil
    return
  end

  local action_request
  local dir = DIRECTIONALS.hasDirectionTriggered()
  if dir then
    if INPUT.isActionDown('MODIFIER') and _canLongWalk() then
      _startLongWalk(dir)
    else
      action_request = {DEFS.ACTION.MOVE, dir}
    end
  end

  if INPUT.wasActionPressed('CONFIRM') then
    action_request = {DEFS.ACTION.INTERACT}
  elseif INPUT.wasActionPressed('CANCEL') then
    action_request = {DEFS.ACTION.IDLE}
  elseif INPUT.wasActionPressed('SPECIAL') then
    action_request = {DEFS.ACTION.USE_SIGNATURE}
  elseif INPUT.wasActionPressed('ACTION_1') then
    action_request = {DEFS.ACTION.PLAY_CARD}
  elseif INPUT.wasActionPressed('ACTION_4') then
    action_request = {DEFS.ACTION.ACTIVATE_WIDGET}
  elseif INPUT.wasActionPressed('ACTION_3') then
    action_request = {DEFS.ACTION.RECEIVE_PACK}
  elseif INPUT.wasActionPressed('EXTRA') then
    action_request = _OPEN_MENU
  elseif INPUT.wasActionPressed('PAUSE') then
    action_request = _SAVE_QUIT
  end

  -- execute action
  if _long_walk then
    if not action_request and _continueLongWalk() then
      _startTask(DEFS.ACTION.MOVE, _long_walk)
    else
      _long_walk = false
    end
  elseif action_request == _OPEN_MENU then
    PLAYSFX 'open-menu'
    SWITCHER.push(GS.ACTION_MENU, _route)
    return
  elseif action_request == _SAVE_QUIT then
    _save_and_quit = true
    return
  elseif action_request then
    _startTask(unpack(action_request))
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
  local param = ACTION.pendingInput(action_slot, controlled_actor, params)
  while param do
    _view.sector:setCooldownPreview(
      ACTION.exhaustionCost(action_slot, controlled_actor, params)
    )
    if param.name == 'choose_dir' then
      SWITCHER.push(GS.PICK_DIR, _view.sector, param['body-block'])
      local dir = coroutine.yield(_task)
      if dir then
        params[param.output] = dir
      else
        return false
      end
    elseif param.name == 'choose_target' then
      SWITCHER.push(
        GS.PICK_TARGET, _view.sector,
        {
          pos = { controlled_actor:getPos() },
          aoe_hint = param['aoe-hint'],
          range_checker = function(i, j)
            return ABILITY.input('choose_target')
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
    elseif param.name == "choose_widget_slot" then
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
    elseif param.name == "choose_consume_list" then
      SWITCHER.push(GS.CONSUME_CARDS, controlled_actor, param.max)
      local args = coroutine.yield(_task)
      if args.consumed then
        params[param.output] = args.consumed
      else
        return false
      end
    end
    param = ACTION.pendingInput(action_slot, controlled_actor, params)
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
  else
    PLAYSFX 'denied'
  end
end


_ACTION[DEFS.ACTION.INTERACT] = function()
  _useAction(DEFS.ACTION.INTERACT)
end

_ACTION[DEFS.ACTION.USE_SIGNATURE] = function()
  PLAYSFX 'ok-menu'
  _useAction(DEFS.ACTION.USE_SIGNATURE)
end

_ACTION[DEFS.ACTION.ACTIVATE_WIDGET] = function()
  local widget_abilities = {}
  local controlled_body = _route.getControlledActor():getBody()
  for _,widget in controlled_body:eachWidget() do
    if widget:getWidgetAbility() then
      table.insert(widget_abilities, widget)
    end
  end
  if widget_abilities[1] then
    PLAYSFX 'open-menu'
    SWITCHER.push(widget_abilities)
  elseif _was_on_menu then
    PLAYSFX 'denied'
    SWITCHER.push(GS.ACTION_MENU, _route)
  end
end

_ACTION[DEFS.ACTION.DRAW_NEW_HAND] = function()
  if MANEUVERS['draw_new_hand'].validate(_route.getControlledActor(), {}) then
    PLAYSFX 'ok-menu'
    _useAction(DEFS.ACTION.DRAW_NEW_HAND)
  elseif _was_on_menu then
    PLAYSFX 'denied'
    SWITCHER.push(GS.ACTION_MENU, _route)
  end
end

_ACTION[DEFS.ACTION.PLAY_CARD] = function()
  PLAYSFX 'ok-menu'
  SWITCHER.push(GS.CARD_SELECT, _route, _view)
  local args = coroutine.yield(_task)
  if args.chose_a_card then
    if args.action_type == 'play' then
      PLAYSFX 'ok-menu'
      if args.card_index > #_view.hand.hand then
        _useAction(DEFS.ACTION.DRAW_NEW_HAND)
      else
        if _useAction(DEFS.ACTION.PLAY_CARD,
                      { card_index = args.card_index }) then
          Signal.emit("actor_used_card", _route.getControlledActor(), index)
        end
      end
    end
  end
end

_ACTION[DEFS.ACTION.CONSUME_CARDS] = function()
  local actor = _route.getControlledActor()
  if actor:getBackBufferSize() > 0 then
    PLAYSFX 'ok-menu'
    SWITCHER.push(GS.MANAGE_BUFFER, actor)
    local args = coroutine.yield(_task)
  elseif _was_on_menu then
    PLAYSFX 'denied'
    SWITCHER.push(GS.ACTION_MENU, _route)
  end
end

_ACTION[DEFS.ACTION.RECEIVE_PACK] = function()
  local actor = _route.getControlledActor()
  if actor:getPrizePackCount() > 0 then
    PLAYSFX 'ok-menu'
    SWITCHER.push(GS.OPEN_PACK, _route, actor:getPrizePacks())
    local args = coroutine.yield(_task)
    if args.pack == nil then return end
    _route.getControlledActor():removePrizePack(args.pack_index)
    _useAction(DEFS.ACTION.RECEIVE_PACK,
               { consumed = args.consumed, pack = args.pack })
  elseif _was_on_menu then
    PLAYSFX 'denied'
    SWITCHER.push(GS.ACTION_MENU, _route)
  end
end

_ACTION[DEFS.ACTION.IDLE] = function()
  _useAction(DEFS.ACTION.IDLE)
end

return state
