
--MODULE FOR THE GAMESTATE: GAME--

local GUI = require 'debug.gui'
local PROFILE = require 'infra.profile'

local Route = require 'domain.route'
local SectorView = require 'domain.view.sectorview'

local state = {}

--LOCAL VARIABLES--

local _route
local _player
local _next_action

local _sector_view
local _gui

--LOCAL FUNCTION--

local function _playTurns(...)
  local request = _route.playTurns(...)

  if request == "playerDead" then
    SWITCHER.switch(GS.START_MENU)
  elseif request == "userTurn" then
    SWITCHER.push(GS.USER_TURN, _route, _sector_view)
  end
  _next_action = nil
end

local function _saveAndQuit()
  local route_data = _route.saveState()
  PROFILE.saveRoute(route_data)
  SWITCHER.switch(GS.START_MENU)
end

--STATE FUNCTIONS--

function state:enter(pre, route_data)

  -- load route
  _route = Route()
  _route.loadState(route_data)

  -- set player
  _player = _route.getControlledActor()

  -- sector view
  local sector = _route.getCurrentSector()
  _sector_view = SectorView(sector)
  _sector_view:addElement("L1", nil, "sector_view")
  _sector_view:lookAt(_player)

  -- start gamestate
  _playTurns()

  -- GUI
  _gui = GUI(_sector_view)
  _gui:addElement("GUI")

end

function state:leave()

  _route.destroyAll()
  _sector_view:destroy()
  _gui:destroy()
  Util.destroyAll()

end

function state:update(dt)

  if not DEBUG then
    if _next_action then
      _playTurns(unpack(_next_action))
    end
    _sector_view:lookAt(_route.getControlledActor() or _player)
  end

  Util.destroyAll()

end

function state:resume(state, args)

  if state == GS.USER_TURN then
    if args == "SAVE_AND_QUIT" then return _saveAndQuit() end
    _next_action = args.next_action
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
