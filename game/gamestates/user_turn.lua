--- MODULE FOR THE GAMESTATE: PLAYER TURN
--  This gamestate rolls out when the player's turn arrives. It pops the action
--  the player chose to do.

-- luacheck: globals SWITCHER GS, no self

local DEFS          = require 'domain.definitions'
local DIR           = require 'domain.definitions.dir'
local ACTION        = require 'domain.action'
local ABILITY       = require 'domain.ability'
local PROFILE       = require 'infra.profile'
local PLAYSFX       = require 'helpers.playsfx'
local ActionHUD     = require 'view.gameplay.actionhud'
local SCHEMATICS    = require 'domain.definitions.schematics'
local INPUT         = require 'input'
local Draw          = require "draw"

local state = {}

--[[ Local Variables ]]--

local _task
local _route
local _next_action
local _view

local _save_and_quit

local _ACTION = {}

--[[ Local functions ]]--
local _checkTutorial
local _update_panel

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

--[[ State Methods ]]--

function state:enter(_, route, view)

  _route = route
  _save_and_quit = false

  _view = view
  _view.action_hud:enableTurn(true)
  _view.action_hud:refreshTurnPreview()
  _view.sector:snapBodyViews()

  _update_panel("isdown")
end

function state:leave()
  _view.action_hud:disableTurnPreview()
end

function state:resume(_, args)

  _update_panel("isdown")

  _view.action_hud:enableTurn(true)
  _resumeTask(args)
end

function state:devmode()
  _view.action_hud:disableTurn()
end

function state:update(_)

  if _checkTutorial() then return end

  if _save_and_quit then return SWITCHER.pop("SAVE_AND_QUIT") end

  _view.sector:lookAt(_route.getControlledActor())

  if _next_action then
    SWITCHER.pop({next_action = _next_action})
    _next_action = nil
    return
  end

  _update_panel("waspressed")

  local action_request, param = _view.action_hud:actionRequested()

  if action_request == ActionHUD.INTERFACE_COMMANDS.SAVE_QUIT then
    _save_and_quit = true
  elseif action_request then
    _startTask(action_request, param)
  end

end

function state:draw()
  Draw.allTables()
end

--[[ Action functions ]]--

local function _useAction(action_slot, params)
  if not ACTION.exists(action_slot) then return false end
  local controlled_actor = _route.getControlledActor()
  params = params or {}
  local param = ACTION.pendingInput(action_slot, controlled_actor, params)
  while param do
    _view.action_hud:activateAbility()
    if param.name == 'choose_dir' then
      _view.action_hud:disableTurn()
      SWITCHER.push(GS.PICK_DIR, _view.sector, param)
      local dir = coroutine.yield(_task)
      if dir then
        params[param.output] = dir
      else
        return false
      end
    elseif param.name == 'choose_target' then
      _view.action_hud:disableTurn()
      SWITCHER.push(
        GS.PICK_TARGET, _view.sector,
        {
          card = ACTION.card(action_slot, controlled_actor, params),
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
    elseif param.name == "choose_consume_list" then
      _view.action_hud:disableTurn()
      SWITCHER.push(GS.CONSUME_CARDS, _view, controlled_actor, param.max)
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

_ACTION[DEFS.ACTION.PLAY_CARD] = function(card_index)
  local actor = _route.getControlledActor()
  local card = actor:getHandCard(card_index)
  if actor:getFocus() >= card:getCost() then
    PLAYSFX 'ok-menu'
    _useAction(DEFS.ACTION.PLAY_CARD, { card_index = card_index })
  else
    PLAYSFX 'denied'
  end
end

_ACTION[DEFS.ACTION.DISCARD_CARD] = function(card_index)
  PLAYSFX 'ok-menu'
  _useAction(DEFS.ACTION.DISCARD_CARD, { card_index = card_index })
end

_ACTION[DEFS.ACTION.CONSUME_CARDS] = function()
  local actor = _route.getControlledActor()
  if actor:getBackBufferSize() > 0 then
    PLAYSFX 'ok-menu'
    _view.action_hud:disableTurn()
    SWITCHER.push(GS.MANAGE_BUFFER, actor)
    coroutine.yield(_task)
  else
    PLAYSFX 'denied'
  end
end

_ACTION[DEFS.ACTION.RECEIVE_PACK] = function()
  local actor = _route.getControlledActor()
  if actor:getPrizePackCount() > 0 then
    PLAYSFX 'ok-menu'
    _view.action_hud:disableTurn()
    SWITCHER.push(GS.OPEN_PACK, _view, _route, actor:getPrizePacks())
    local args = coroutine.yield(_task)
    if args.pack == nil then return end
    _route.getControlledActor():removePrizePack(args.pack_index)
    _useAction(DEFS.ACTION.RECEIVE_PACK,
               { consumed = args.consumed, pack = args.pack })
  else
    PLAYSFX 'denied'
  end
end

_ACTION[DEFS.ACTION.IDLE] = function()
  _useAction(DEFS.ACTION.IDLE)
end

function _update_panel(mode)

  if mode == "isdown" then
    if INPUT.isActionDown('STATUS') then
      _view.actor:show()
    else
      _view.actor:hide()
    end
  elseif mode == "waspressed" then
    if INPUT.wasActionPressed('STATUS') then
      _view.actor:show()
    elseif INPUT.wasActionReleased('STATUS') then
      _view.actor:hide()
    end
  else
    error("Not a valid mode to update panel")
  end

end

function _checkTutorial()
  --Check for time seeing enemy
  if not PROFILE.getTutorial("open_hand") then
    local player = _route.getPlayerActor()
    if player then
      local player_i, player_j = player:getPos()
      local hostile_bodies = player:getHostileBodies()
      for _,body in ipairs(hostile_bodies) do
        local enemy_i, enemy_j = body:getPos()
        if math.abs(player_i - enemy_i) + math.abs(player_j - enemy_j) <= 1 then
          SWITCHER.push(GS.TUTORIAL_HINT, "open_hand")
          return true
        end
      end
    end
  end
  -- Check for first time seeing an altar
  if not PROFILE.getTutorial("altar") then
    local player = _route.getPlayerActor()
    if player then
      local altars = player:getVisibleTilesIf(function (sector, i, j)
        local tile = sector:getTile(i, j)
        return tile and tile.type == SCHEMATICS.ALTAR
      end)
      if #altars > 0 then
        local altar_tile = altars[1]
        local player_i, player_j = player:getPos()
        local relative_pos = { altar_tile.i - player_i,
                               altar_tile.j - player_j }
        SWITCHER.push(GS.TUTORIAL_HINT, "altar", relative_pos)
        return true
      end
    end
  end
end

return state
