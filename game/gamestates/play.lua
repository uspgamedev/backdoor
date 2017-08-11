--MODULE FOR THE GAMESTATE: GAME--

local DIR = require 'domain.definitions.dir'
local Map = require "domain.map"
local Body = require "domain.body"
local Actor = require "domain.actor"
local MapView = require "domain.mapview"
local action = require 'domain.action'

local state = {}

--LOCAL VARIABLES--

local _switch --If gamestate should change to another one
local _map_view
local _current_map

local _player
local _next_player_action

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

  if DIR[key] then
    _next_player_action = action.MOVE(_current_map, _player, key)
  end

	if key == "r" then
		_switch = "menu"
	else
    	Util.defaultKeyPressed(key)
	end

end

--Return state functions
return state

