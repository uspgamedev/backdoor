--MODULE FOR THE GAMESTATE: GAME--

local Map = require "domain.map"
local Body = require "domain.body"
local Actor = require "domain.actor"
local MapView = require "domain.mapview"

local state = {}

--LOCAL VARIABLES--

local _switch --If gamestate should change to another one
local _map_view
local _current_map

local _turn_delay = 1

--LOCAL FUNCTIONS--

--STATE FUNCTIONS--

function state:enter()

  _current_map = Map(10,10)
  _map_view = MapView(_current_map)
  _map_view:addElement("L1", nil, "map_view")

  local body = Body(100)
  local actor = Actor(body)
  _current_map:putActor(actor, 8, 4)

end

function state:leave()

	Util.destroyAll("force")

end

function state:update(dt)

  _turn_delay = _turn_delay - dt
  if _turn_delay < 0 then
    _current_map:playTurns()
    _turn_delay = 1
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
		_switch = "MENU"
	else
    	Util.defaultKeyPressed(key)
	end

end

--Return state functions
return state
