
--MODULE FOR THE GAMESTATE: GAME--

local GUI         = require 'debug.gui'
local PROFILE     = require 'infra.profile'

local Route       = require 'domain.route'
local SectorView  = require 'domain.view.sectorview'
local HandView    = require 'domain.view.handview'
local WidgetView  = require 'domain.view.widgetview'
local ActorView   = require 'domain.view.actorview'

local state = {}

--LOCAL VARIABLES--

local _route
local _player
local _next_action

local _view
local _gui

--LOCAL FUNCTION--

local function _playTurns(...)
  local request = _route.playTurns(...)

  if request == "playerDead" then
    SWITCHER.switch(GS.START_MENU)
  elseif request == "userTurn" then
    SWITCHER.push(GS.USER_TURN, _route, _view)
  elseif request == "changeSector" then
    return _playTurns()
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

  -- View table
  _view = {}

  -- sector view
  local sector = _route.getCurrentSector()
  _view.sector = SectorView(_route)
  _view.sector:addElement("L1", nil, "sector_view")
  _view.sector:lookAt(_player)

  -- hand view
  _view.hand = HandView(_route)
  _view.hand:addElement("HUD", nil, "hand_view")
  Signal.register(
    "actor_draw",
    function(actor, card)
      _view.hand:addCard(actor,card)
    end
  )
  Signal.register(
    "actor_used_card",
    function(actor, card_index)
      _view.hand:removeCard(actor,card_index)
    end
  )

  -- Widget view
  _view.widget = WidgetView(_route)
  _view.widget:addElement("GUI")

  -- Actor view
  _view.actor = ActorView(_route)
  _view.actor:addElement("HUD")

  -- start gamestate
  _playTurns()

  -- GUI
  _gui = GUI(_view.sector)
  _gui:addElement("GUI")

end

function state:leave()

  _route.destroyAll()
  for _,view in pairs(_view) do
    view:destroy()
  end
  _gui:destroy()
  Util.destroyAll()

end

function state:update(dt)

  if not DEBUG then
    if _next_action then
      _playTurns(unpack(_next_action))
    end
    _view.sector:lookAt(_route.getControlledActor() or _player)
  end

  Util.destroyAll()

end

function state:resume(state, args)

  if state == GS.USER_TURN then
    if args == "SAVE_AND_QUIT" then return _saveAndQuit() end
    if args == "EXIT_SECTOR" then return _exitSector() end
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

