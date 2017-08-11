--MODULE FOR THE GAMESTATE: GAME--

local DIR = require 'domain.definitions.dir'
local Map = require "domain.map"
local Body = require "domain.body"
local Actor = require "domain.actor"
local action = require 'domain.action'
local MapView = require "domain.view.mapview"

local GUI = require 'debug.gui'

local state = {}

--LOCAL VARIABLES--

local _switch --If gamestate should change to another one
local _map_view
local _current_map

local _player
local _next_player_action

local _gui

--LOCAL FUNCTIONS--

--STATE FUNCTIONS--

function state:enter()

  _current_map = Map(8,8)
  _map_view = MapView(_current_map)
  _map_view:addElement("L1", nil, "map_view")

  local rand = love.math.random
  local monster_behavior = require 'domain.behaviors.random_walk'
  for _=1,5 do
    local body = Body(100)
    local actor = Actor(body, monster_behavior)
    local i, j = rand(_current_map.h), rand(_current_map.w)
    _current_map:putActor(actor, i, j)
  end

  local body = Body(137)
  _player = Actor(body,
    function (self, map) return select(2,coroutine.yield()) end
  )
  local i, j = rand(_current_map.h), rand(_current_map.w)
  _current_map:putActor(_player, i, j)

  _current_map:playTurns()
  _next_player_action = nil
  
  _gui = GUI(_current_map)
  _gui:addElement("GUI")

end

function state:leave()

	Util.destroyAll("force")

end

function state:update(dt)

  if _next_player_action then
    _current_map:playTurns(_next_player_action)
    _next_player_action = nil
  end

	if _switch == "menu" then
		--Gamestate.switch(GS.MENU)
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

  if DIR[key] then
    _next_player_action = action.MOVE(_current_map, _player, key)
  end

	if key == "r" then
		_switch = "menu"
	else
    	Util.defaultKeyPressed(key)
	end

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

