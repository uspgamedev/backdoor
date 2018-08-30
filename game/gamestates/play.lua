
--MODULE FOR THE GAMESTATE: GAME--

local INPUT       = require 'input'
local GUI         = require 'debug.gui'
local PROFILE     = require 'infra.profile'
local PLAYSFX     = require 'helpers.playsfx'

local Route       = require 'domain.route'
local SectorView  = require 'view.sector'
local HandView    = require 'view.hand'
local BufferView  = require 'view.buffer'
local ActorView   = require 'view.actor'
local FocusBar    = require 'view.focusbar'
local Announcement = require 'view.announcement'
local FadeView    = require 'view.fade'
local SoundTrack  = require 'view.soundtrack'

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
local _alert

--LOCAL FUNCTION--

local function _saveRoute()
  PROFILE.saveRoute(_route.saveState())
end

local function _playTurns(...)
  local request,extra = _route.playTurns(...)

  if request == "playerDead" then
    SWITCHER.switch(GS.START_MENU)
  elseif request == "userTurn" then
    _saveRoute()
    SWITCHER.push(GS.USER_TURN, _route, _view, _alert)
    _alert = false
  elseif request == "changeSector" then
    _activity:changeSector(...)
  elseif request == "report" then
    _view.sector:startVFX(extra)
    _alert = _alert or (extra.type == 'text_rise')
                    and (extra.body == _player:getBody())
    SWITCHER.push(GS.ANIMATION, _view.sector)
  end
  _next_action = nil
end

function _activity:saveAndQuit()
  local fade_view = FadeView(FadeView.STATE_UNFADED)
  _saveRoute()
  fade_view:addElement("GUI")
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
  fade_view:addElement("GUI")
  fade_view:fadeOutAndThen(self.resume)
  self.yield()
  local change_sector_ok = _route.checkSector()
  assert(change_sector_ok, "Sector Change fuck up")
  _view.sector:sectorChanged()
  _soundtrack.playTheme(_route.getCurrentSector():getTheme())
  MAIN_TIMER:after(FadeView.FADE_TIME, self.resume)
  self.yield()
  fade_view:fadeInAndThen(self.resume)
  self.yield()
  fade_view:destroy()
  return _playTurns()
end

function _activity:fadeInGUI()
  local fade_view = FadeView(FadeView.STATE_FADED)
  fade_view:addElement("GUI")
  MAIN_TIMER:after(FadeView.FADE_TIME, self.resume)
  self.yield()
  fade_view:fadeInAndThen(self.resume)
  self.yield()
  fade_view:destroy()
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
  _view.hand:addElement("HUD_BG", nil, "hand_view")
  Signal.register(
    "actor_draw",
    function(actor, card)
      _view.hand:addCard(actor,card)
    end
  )

  -- Buffer views
  _view.frontbuffer = BufferView.newFrontBufferView(_route)
  _view.frontbuffer:addElement("HUD_BG", nil, "frontbuffer_view")
  _view.backbuffer = BufferView.newBackBufferView(_route)
  _view.backbuffer:addElement("HUD_BG", nil, "backbuffer_view")

  -- Actor view
  _view.actor = ActorView(_route)
  _view.actor:addElement("HUD_BG")

  -- Focus bar
  _view.focusbar = FocusBar(_route)
  _view.focusbar:addElement("HUD")

  -- Announcement box
  _view.announcement = Announcement()
  _view.announcement:addElement("HUD")

  -- GUI
  _gui = GUI(_view.sector)
  _gui:addElement("GUI")

  -- Sound Track
  _soundtrack = SoundTrack()
  _soundtrack.playTheme(sector:getTheme())

  -- start gamestate
  _playTurns()

  -- set player
  _player = _route.getControlledActor()

  _activity:fadeInGUI()

end

function state:leave()

  _saveRoute()
  _route.destroyAll()
  for _,view in pairs(_view) do
    view:destroy()
  end
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

    if INPUT.wasAnyPressed(0.5) then
      _alert = true
    end

    if _next_action then
      _playTurns(unpack(_next_action))
    end
    _view.sector:lookAt(_route.getControlledActor() or _player)
  end

  Util.destroyAll()

end

function state:resume(state, args)

  if state == GS.USER_TURN then
    if args == "SAVE_AND_QUIT" then return _activity:saveAndQuit() end
    _next_action = args.next_action
  elseif state == GS.ANIMATION then
    _alert = _alert or args
    _playTurns()
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
