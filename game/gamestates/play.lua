--MODULE FOR THE GAMESTATE: GAME--

local INPUT       = require 'input'
local GUI         = require 'devmode.gui'
local PROFILE     = require 'infra.profile'
local PLAYSFX     = require 'helpers.playsfx'

local GameplayView = require 'view.gameplay'
local Route       = require 'domain.route'
local FadeView    = require 'view.fade'
local SoundTrack  = require 'view.soundtrack'
local Util        = require "steaming.util"
local Draw        = require "draw"

local Activity    = require 'common.activity'

local state = {}

--LOCAL VARIABLES--

local _activity = Activity()

local _route
local _player
local _next_action

local _view
local _gui
local _soundtrack

local _switch_to

--LOCAL FUNCTION--

local function _saveRoute()
  PROFILE.saveRoute(_route.saveState())
end

local function _playTurns(...)
  local request, extra = _route.playTurns(...)

  if request == "playerDead" then
    _view.action_hud:destroy()
    _view.actor:destroy()
    SWITCHER.push(GS.GAMEOVER, _player, _view)
  elseif request == "userTurn" then
    _saveRoute()
    SWITCHER.push(GS.USER_TURN, _route, _view)
  elseif request == "changeSector" then
    _activity:changeSector(...)
  elseif request == "report" then
    
    SWITCHER.push(GS.ANIMATION, _route, _view, extra)
  end
  _next_action = nil
end

local function _initFrontend()

  _view:setup(_route)

  -- GUI
  _gui = GUI(_view.sector)
  _gui:register("GUI")

  -- Sound Track
  _soundtrack = SoundTrack()
  _soundtrack.playTheme(_route.getCurrentSector():getTheme()['bgm'])

end

function _activity:saveAndQuit()
  local fade_view = FadeView(FadeView.STATE_UNFADED)
  _saveRoute()
  fade_view:register("GUI")
  fade_view:fadeOutAndThen(self.resume)
  self.yield()
  SWITCHER.switch(GS.START_MENU)
  fade_view:fadeInAndThen(self.resume)
  self.yield()
  fade_view:destroy()
end

function _activity:changeSector()
  local fade_view = FadeView(FadeView.STATE_UNFADED)
  PLAYSFX 'change-sector'
  fade_view:register("GUI")
  fade_view:fadeOutAndThen(self.resume)
  self.yield()
  local change_sector_ok = _route.checkSector()
  assert(change_sector_ok, "Sector Change fuck up")
  _view.sector:sectorChanged()
  _soundtrack.playTheme(_route.getCurrentSector():getTheme()['bgm'])
  MAIN_TIMER:after(FadeView.FADE_TIME, self.resume)
  self.yield()
  fade_view:fadeInAndThen(self.resume)
  self.yield()
  fade_view:destroy()
  return _playTurns()
end

function _activity:fadeInGUI()
  local fade_view = FadeView(FadeView.STATE_FADED)
  fade_view:register("GUI")
  MAIN_TIMER:after(FadeView.FADE_TIME, self.resume)
  self.yield()
  fade_view:fadeInAndThen(self.resume)
  self.yield()
  fade_view:destroy()
end

--STATE FUNCTIONS--

function state:init()
end

function state:enter(pre, route_data)

  -- load route
  _route = Route()
  _route.loadState(route_data)

  -- create general gameplay view
  _view = GameplayView()

  -- start gamestate
  _playTurns()

  -- set player
  _player = _route.getControlledActor()

  _initFrontend()

  _activity:fadeInGUI()

end

function state:leave()

  _saveRoute()
  _route.destroyAll()
  _view:destroy()
  _gui:destroy()
  _soundtrack.playTheme(nil)
  Util.destroyAll()

end

function state:update(dt)
  if not DEBUG then

    --FIXME:this doesn't need to happen every update (I think)
    if _route.getControlledActor() or _player then
      _view.sector:updateFov(_route.getControlledActor() or _player)
    else
      print("oops")
    end

    if _next_action then
      _playTurns(unpack(_next_action))
    end
    _view.sector:lookAt(_route.getControlledActor() or _player)
  end

end

function state:resume(state, args)

  if state == GS.USER_TURN then
    if args == "SAVE_AND_QUIT" then return _activity:saveAndQuit() end
    _next_action = args.next_action
  elseif state == GS.ANIMATION then
    _playTurns()
  elseif state == GS.GAMEOVER then
    SWITCHER.switch(GS.START_MENU)
  end

end

function state:draw()
  Draw.allTables()
end

function state:keypressed(key)
  if key == 'f1' then DEBUG = true end
end

--Return state functions
return state
