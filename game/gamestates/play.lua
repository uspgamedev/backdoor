--MODULE FOR THE GAMESTATE: GAME--

local DB = require 'database'
local DIR = require 'domain.definitions.dir'
local Route = require 'domain.route'
local Map = require "domain.map"
local Body = require "domain.body"
local Actor = require "domain.actor"
local action = require 'domain.action'
local MapView = require "domain.view.mapview"

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
  until _current_map:valid(i, j)
  return i, j
end

local function _playTurns()
  _controlled_actor = _current_map:playTurns(_next_action)
  _next_action = nil
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
  
  _gui = GUI(_map_view)
  _gui:addElement("GUI")

end

function state:leave()

	Util.destroyAll("force")

end

function state:update(dt)

  if not DEBUG then
    if _next_action then
      _playTurns()
    end
    _map_view:lookAt(_controlled_actor or _player)
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
    if DIR[key] and _controlled_actor then
      _next_action = action.MOVE(_current_map, _controlled_actor, key)
    end
  end

  Util.defaultKeyPressed(key)

end

function state:textinput(t)
  imgui.TextInput(t)
end

function state:keyreleased(key)
  imgui.KeyReleased(key)
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

