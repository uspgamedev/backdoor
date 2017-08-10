--MODULE FOR THE GAMESTATE: GAME--

local Map = require "domain.map"
local MapView = require "domain.mapview"

local state = {}

--LOCAL VARIABLES--

local switch --If gamestate should change to another one

--LOCAL FUNCTIONS--

--STATE FUNCTIONS--

function state:enter()

  local map = Map(10,10)
  local map_view = MapView(map)
  map_view:addElement("L1", nil, "map_view")

end

function state:leave()

	Util.destroyAll("force")

end


function state:update(dt)

	if switch == "menu" then
		--Gamestate.switch(GS.MENU)
	end

	Util.destroyAll()

end

function state:draw()

    Draw.allTables()

end

function state:keypressed(key)

	if key == "r" then
		switch = "MENU"
	else
    	Util.defaultKeyPressed(key)
	end

end

--Return state functions
return state
