--MODULE FOR THE GAMESTATE: GAME--

local Map = require "domain.map"
local Body = require "domain.body"
local Actor = require "domain.actor"
local MapView = require "domain.mapview"
local AI = require 'domain.ai'
local action = require 'domain.action'

local state = {}

--LOCAL VARIABLES--

local _switch --If gamestate should change to another one
local _map_view
local _current_map

local _player
local _refresh

--LOCAL FUNCTIONS--

--STATE FUNCTIONS--

function state:enter()

  _current_map = Map(8,8)
  _map_view = MapView(_current_map)
  _map_view:addElement("L1", nil, "map_view")

  local rand = love.math.random
  for _=1,5 do
    local body = Body(100)
    local actor = Actor(body)
    local i, j = rand(_current_map.h), rand(_current_map.w)
    AI.addActor(actor, 'random_walk')
    _current_map:putActor(actor, i, j)
  end

  local body = Body(137)
  _player = Actor(body)
  local i, j = rand(_current_map.h), rand(_current_map.w)
  _current_map:putActor(_player, i, j)

  _refresh = true

end

function state:leave()

	Util.destroyAll("force")

end

function state:update(dt)

  if _refresh then
    _current_map:playTurns()
    _refresh = false
  end

	if _switch == "menu" then
		--Gamestate.switch(GS.MENU)
	end

	Util.destroyAll()

end

function state:draw()

    Draw.allTables()

end

local dir_keys = {
  left = {0,-1},
  right = {0,1},
  down = {1,0},
  up = {-1,0},
}

function state:keypressed(key)

  local dir = dir_keys[key] if dir then
    local i, j = unpack(_current_map.bodies[_player.body])
    _player:setAction(action.MOVE(_current_map, _player, i + dir[1],
                                  j + dir[2]))
    _refresh = true
  end

	if key == "r" then
		_switch = "menu"
	else
    	Util.defaultKeyPressed(key)
	end

end

--Return state functions
return state
