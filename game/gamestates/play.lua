--MODULE FOR THE GAMESTATE: GAME--

-- luacheck: globals SWITCHER GS MAIN_TIMER, no self

local PLAYSFX     = require 'helpers.playsfx'
local PROFILE     = require 'infra.profile'
local RUNFLAGS    = require 'infra.runflags'

local GameplayView = require 'view.gameplay'
local Route       = require 'domain.route'
local FadeView    = require 'view.fade'
local Util        = require "steaming.util"
local Draw        = require "draw"
local SoundTrack  = require 'view.soundtrack'

local Activity    = require 'common.activity'

local state = {}

--LOCAL VARIABLES--

local _activity = Activity()

local _route
local _player
local _next_action

local _view
local _soundtrack

--Forward functions declaration
local _updateSoundtrack

--LOCAL FUNCTION--

local function _saveRoute()
  PROFILE.saveRoute(_route.saveState())
end

local function _persistRoute()
  if PROFILE.getTutorial("finished_tutorial") then
    _saveRoute()
    PROFILE.persistRoute()
  end
end

local function _playTurns(...)

  local request, extra = _route.playTurns(...)

  _updateSoundtrack()

  if request == "playerDead" then
    _view.action_hud:destroy()
    _view.actor:destroy()
    _view.action_hud:disableTurn()
    SWITCHER.push(GS.GAMEOVER, _player, _view)
  elseif request == "playerWin" then
    _route.win()
    _view.action_hud:destroy()
    _view.actor:destroy()
    _view.action_hud:disableTurn()
    SWITCHER.push(GS.WIN, _player, _view)
  elseif request == "userTurn" then
    _saveRoute()
    SWITCHER.push(GS.USER_TURN, _route, _view)
  elseif request == "changeSector" then
    _view.action_hud:disableTurn()
    _activity:changeSector(...)
  elseif request == "report" then
    local player = _route.getPlayerActor()
    local body = extra.body or (extra.actor and extra.actor:getBody())
    local pos = extra.pos
    if body and player:canSee(body) or
       pos and player:canSeePosition(unpack(pos)) then
      if extra.actor ~= player then
        _view.action_hud:disableTurn()
      end
      SWITCHER.push(GS.ANIMATION, _route, _view, extra)
    else
      return _playTurns()
    end
  end
  _next_action = nil
end

local function _initFrontend()

  _view:setup(_route)

  -- GUI
  if RUNFLAGS.DEVELOPMENT then
    local gui = Util.findId('devmode-gui')
    gui.sector_view = _view.sector
  end

end

function _activity:saveAndQuit()
  local fade_view = FadeView(FadeView.STATE_UNFADED)
  _persistRoute()
  fade_view:register("GUI")
  fade_view:fadeOutAndThen(self.resume)
  self.wait()
  SWITCHER.switch(GS.START_MENU)
  fade_view:fadeInAndThen(self.resume)
  self.wait()
  fade_view:destroy()
end

function _activity:changeSector()
  local fade_view = FadeView(FadeView.STATE_UNFADED)
  PLAYSFX 'change-sector'
  fade_view:register("GUI")
  fade_view:fadeOutAndThen(self.resume)
  self.wait()
  local change_sector_ok = _route.checkSector()
  assert(change_sector_ok, "Sector Change fuck up")
  _view.sector:sectorChanged()
  _soundtrack:playTheme(_route.getCurrentSector():getTheme())
  MAIN_TIMER:after(FadeView.FADE_TIME, self.resume)
  self.wait()
  fade_view:fadeInAndThen(self.resume)
  self.wait()
  fade_view:destroy()
  return _playTurns()
end

function _activity:fadeInGUI()
  local fade_view = FadeView(FadeView.STATE_FADED)
  fade_view:register("GUI")
  MAIN_TIMER:after(FadeView.FADE_TIME, self.resume)
  self.wait()
  fade_view:fadeInAndThen(self.resume)
  self.wait()
  fade_view:destroy()
end

--STATE FUNCTIONS--

function state:init() -- luacheck: no self
end

function state:enter(_, route_data)

  -- load route
  _route = Route()
  _route.loadState(route_data)

  -- setup soundtrack
  _soundtrack = SoundTrack:get()
  _soundtrack:playTheme(_route.getCurrentSector():getTheme())

  -- create general gameplay view
  _view = GameplayView()

  _initFrontend()

  -- start gamestate
  _playTurns()

  -- set player
  _player = _route.getControlledActor()

  _activity:fadeInGUI()

end

function state:leave()

  _persistRoute()
  _route.destroyAll()
  _view:destroy()
  if RUNFLAGS.DEVELOPMENT then
    Util.findId('devmode-gui').sector_view = nil
  end
  _soundtrack:clearTheme()
  Util.destroyAll()

end

function state:update(_)
  --FIXME:this doesn't need to happen every update (I think)
  _player = _player or _route.getControlledActor() or _route.getPlayerActor()
  if _player then
    _view.sector:updateFov(_player)
  else
    return error("missing player")
  end

  if _next_action then
    _playTurns(unpack(_next_action))
  end
  _view.sector:lookAt(_player)
end

function state:resume(from, args)

  if from == GS.USER_TURN then
    if args == "SAVE_AND_QUIT" then return _activity:saveAndQuit() end
    _next_action = args.next_action
  elseif from == GS.ANIMATION then
    _playTurns()
  elseif from == GS.GAMEOVER or from == GS.WIN then
    SWITCHER.switch(GS.START_MENU)
  end

end

function state:draw()
  Draw.allTables()
end

--Local functions

function _updateSoundtrack()
  if _soundtrack then

    --Check for danger
    local controlled_actor = _route.getControlledActor()
    if controlled_actor then
      local hostile_bodies = controlled_actor:getHostileBodies()
      if #hostile_bodies > 0 then
        _soundtrack:enableTrack("danger")
      else
        _soundtrack:disableTrack("danger")
      end
    end

  end
end

--Return state functions
return state
