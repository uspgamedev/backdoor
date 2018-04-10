
--MODULE FOR THE GAMESTATE: GAME--

local GUI         = require 'debug.gui'
local PROFILE     = require 'infra.profile'

local Route       = require 'domain.route'
local SectorView  = require 'view.sector'
local HandView    = require 'view.hand'
local ActorView   = require 'view.actor'
local WidgetView  = require 'view.widgethud'
local FadeView    = require 'view.fade'

local state = {}

--LOCAL VARIABLES--

local _route
local _player
local _next_action

local _view
local _gui

local _switch_to
local _alert

--LOCAL FUNCTION--

local function _playTurns(...)
  local request,extra = _route.playTurns(...)

  if request == "playerDead" then
    SWITCHER.switch(GS.START_MENU)
  elseif request == "userTurn" then
    SWITCHER.push(GS.USER_TURN, _route, _view, _alert)
    _alert = false
  elseif request == "changeSector" then
    local fade_view = FadeView(FadeView.STATE_UNFADED)
    fade_view:addElement("GUI")
    fade_view:fadeOutAndThen(function()
      local change_sector_ok = _route.checkSector()
      assert(change_sector_ok, "Sector Change fuck up")
      _view.sector:sectorChanged()
      MAIN_TIMER:after(FadeView.FADE_TIME, function()
        fade_view:fadeInAndThen(function()
          fade_view:destroy()
          return _playTurns()
        end)
      end)
    end)
  elseif request == "report" then
    _view.sector:startVFX(extra)
    _alert = _alert or (extra.type == 'number_rise')
                    and (extra.body == _player:getBody())
    SWITCHER.push(GS.ANIMATION, _view.sector)
  end
  _next_action = nil
end

local function _saveAndQuit()
  local fade_view = FadeView(FadeView.STATE_UNFADED)
  local route_data = _route.saveState()
  PROFILE.saveRoute(route_data)
  fade_view:addElement("GUI")
  fade_view:fadeOutAndThen(function()
    SWITCHER.switch(GS.START_MENU)
    fade_view:fadeInAndThen(function()
      fade_view:destroy()
    end)
  end)
end

--STATE FUNCTIONS--

function state:init()
  _alert = false
end

function state:enter(pre, route_data)

  -- load route
  _route = Route()
  _route.loadState(route_data)

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

  -- Actor view
  _view.actor = ActorView(_route)
  _view.actor:addElement("HUD")

  -- Widget view
  _view.widget = WidgetView(_route)
  _view.widget:addElement("HUD")

  -- GUI
  _gui = GUI(_view.sector)
  _gui:addElement("GUI")

  -- start gamestate
  _playTurns()

  -- set player
  _player = _route.getControlledActor()

  local fade_view = FadeView(FadeView.STATE_FADED)
  fade_view:addElement("GUI")
  MAIN_TIMER:after(FadeView.FADE_TIME, function()
    fade_view:fadeInAndThen(function()
      fade_view:destroy()
    end)
  end)

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
    MAIN_TIMER:update(dt)
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
  elseif state == GS.ANIMATION then
    _playTurns()
  end

end

function state:draw()

  --FIXME:this doesn't need to happen every update (I think)
  if _route.getControlledActor() or _player then
    _view.sector:updateFov(_route.getControlledActor() or _player)
  else
    print("oops")
  end

  Draw.allTables()

end

function state:keypressed(key)
  if key == 'f1' then DEBUG = true end
end

--Return state functions
return state
