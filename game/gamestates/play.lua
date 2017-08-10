--MODULE FOR THE GAMESTATE: GAME--

local Map = require "domain.map"
local Body = require "domain.body"
local Actor = require "domain.actor"
local MapView = require "domain.mapview"
local AI = require 'domain.ai'

local state = {}

--LOCAL VARIABLES--

local _switch --If gamestate should change to another one
local _map_view
local _current_map

local _turn_time = 1
local _turn_delay = _turn_time

--LOCAL FUNCTIONS--

--STATE FUNCTIONS--

function state:enter()

  _current_map = Map(10,10)
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

end

function state:leave()

	Util.destroyAll("force")

end

function state:update(dt)

  _turn_delay = _turn_delay - dt
  if _turn_delay < 0 then
    _current_map:playTurns()
    _turn_delay = _turn_time
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

	if key == "r" then
		_switch = "menu"
	else
    	Util.defaultKeyPressed(key)
	end

end

--Return state functions
return state
