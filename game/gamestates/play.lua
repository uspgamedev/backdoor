--MODULE FOR THE GAMESTATE: GAME--

local DB = require 'database'
local DIR = require 'domain.definitions.dir'
local Route = require 'domain.route'
local Map = require 'domain.map'
local Body = require 'domain.body'
local Actor = require 'domain.actor'
local MapView = require 'domain.view.mapview'
local INPUT = require 'infra.input'
local ACTION = require 'domain.action'
local CONTROL = require 'infra.control'

local GUI = require 'debug.gui'

local state = {}

--LOCAL VARIABLES--

local _switch --If gamestate should change to another one
local _route
local _map_view
local _current_map

local _player
local _next_action
local _controlled_actor

local _gui

--LOCAL FUNCTIONS--

local function _makeActor(bodyspec, actorspec, i, j)
  local bid, body = _route.register(Body(bodyspec))
  local aid, actor = _route.register(Actor(actorspec))
  actor:setBody(bid)
  _current_map:putActor(actor, i, j)
  return actor
end

local function _randomValidTile()
  local rand = love.math.random
  local i, j
  repeat
    i, j = rand(_current_map.h), rand(_current_map.w)
until _current_map:isValid(i, j)
  return i, j
end

local function _playTurns(...)
  _controlled_actor, request, target_opt = _current_map:playTurns(...)
  _next_action = nil

  return request, target_opt
end

--STATE FUNCTIONS--

function state:enter()

  _route = Route()

  _current_map = Map(20,20)
  _route.register(_current_map)
  _map_view = MapView(_current_map)
  _map_view:addElement("L1", nil, "map_view")

  for _=1,5 do
    _makeActor('slime', 'dumb', _randomValidTile())
  end

  _player = _makeActor('hearthborn', 'player', _randomValidTile())
  _map_view:lookAt(_player)

  _playTurns()

  local move = function (dir)
      if _controlled_actor then
        _next_action = ACTION.MOVE(_current_map, _controlled_actor, dir)
      end
  end
  local use_primary_action = function ()
      if _controlled_actor then
        _next_action = ACTION.PRIMARY(_current_map, _controlled_actor)
      end
  end
  Signal.register("move", move)
  Signal.register("widget_1", use_primary_action)

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

  _gui = GUI(_map_view)
  _gui:addElement("GUI")

end

function state:leave()

	Util.destroyAll("force")

end

function state:update(dt)

  if not DEBUG then
    INPUT.update()
    if _next_action then
      local request
      request, target_opt = _playTurns(_next_action)
      if request == 'pick_target' then
        return Gamestate.push(GS.PICK_TARGET, _controlled_actor, _current_map, _map_view, target_opt)
      end
    end
    _map_view:lookAt(_controlled_actor or _player)
  end

	Util.destroyAll()

end

function state:resume(state, args)
  if state == GS.PICK_TARGET then

    if args.target_is_valid then
        _playTurns(args.pos)
    else
        --do other stuff
    end

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
