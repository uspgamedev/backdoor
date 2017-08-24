--MODULE FOR THE GAMESTATE: GAME--

local ACTION = require 'domain.action'
local DB = require 'database'
local DIR = require 'domain.definitions.dir'
local INPUT = require 'infra.input'
local CONTROL = require 'infra.control'
local GUI = require 'debug.gui'

local Route = require 'domain.route'
local Sector = require 'domain.sector'
local Body = require 'domain.body'
local Actor = require 'domain.actor'
local SectorView = require 'domain.view.sectorview'

local state = {}

--LOCAL VARIABLES--

local _route
local _sector_view
local _current_sector

local _player
local _next_action
local _controlled_actor
local _task

local _gui

--LOCAL FUNCTIONS--

local function _makeActor(bodyspec, actorspec, i, j)
  local bid, body = _route.register(Body(bodyspec))
  local aid, actor = _route.register(Actor(actorspec))
  actor:setBody(bid)
  _current_sector:putActor(actor, i, j)
  return actor
end

local function _randomValidTile()
  local rand = love.math.random
  local i, j
  repeat
    i, j = rand(_current_sector.h), rand(_current_sector.w)
until _current_sector:isValid(i, j)
  return i, j
end

local function _playTurns(...)
  local request, target_opt
  _controlled_actor, request, target_opt = _current_sector:playTurns(...)
  _next_action = nil

  return request, target_opt
end

local function _moveActor(dir)
  local i, j = _controlled_actor:getPos()
  dir = DIR[dir]
  i, j = i+dir[1], j+dir[2]
  if _current_sector:isValid(i,j) then
    _next_action = {'MOVE', { pos = {i,j} }}
  end
end

local function _usePrimaryAction()
  local action_name = _controlled_actor:getAction('PRIMARY')
  local params = {}
  for _,param in ACTION.paramsOf(action_name) do
    if param[1] == 'choose_target' then
      SWITCHER.push(
        GS.PICK_TARGET, _controlled_actor, _current_sector, _sector_view,
        {
          pos = {_controlled_actor:getPos()},
          valid_position_func = function(i, j)
            return _current_sector:isInside(i,j) and _current_sector:getBodyAt(i,j)
          end
        }
      )
      local args = coroutine.yield(_task)
      if args.target_is_valid then
        params[param[3]] = _current_sector:getBodyAt(unpack(args.pos))
      else
        return
      end
    end
  end
  _next_action = {'PRIMARY', params}
end

local function _resumeTask(...)
  if _task then
    local _
    _, _task = assert(coroutine.resume(_task, ...))
  end
end

local function _makeSignalHandler(callback)
  return function (...)
    if _controlled_actor then
      _task = coroutine.create(callback)
      return _resumeTask(...)
    end
  end
end

--STATE FUNCTIONS--

function state:enter()

  _route = Route()

  _current_sector = Sector("sector01")
  _route.register(_current_sector)
  _sector_view = SectorView(_current_sector)
  _sector_view:addElement("L1", nil, "sector_view")

  for _=1,5 do
    _makeActor('slime', 'dumb', _randomValidTile())
  end

  _player = _makeActor('hearthborn', 'player', _randomValidTile())
  _sector_view:lookAt(_player)

  _playTurns()

  Signal.register("move", _makeSignalHandler(_moveActor))
  Signal.register("widget_1", _makeSignalHandler(_usePrimaryAction))

  local signals = {
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
  for name, signal in pairs(signals) do
    signals[name] = function ()
      Signal.emit(unpack(signal))
    end
  end
  CONTROL.set_map(signals)

  _gui = GUI(_sector_view)
  _gui:addElement("GUI")

end

function state:leave()

  Util.destroyAll("force")

end

function state:update(dt)

  if not DEBUG then
    INPUT.update()
    if _next_action then
      _playTurns(unpack(_next_action))
    end
    _sector_view:lookAt(_controlled_actor or _player)
  end

  Util.destroyAll()

end

function state:resume(state, args)
  if state == GS.PICK_TARGET then

    _resumeTask(args)

  end
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
