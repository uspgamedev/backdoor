--MODULE FOR THE GAMESTATE: MAIN MENU--
local DB              = require 'database'
local MENU            = require 'infra.menu'
local DIRECTIONALS    = require 'infra.dir'
local INPUT           = require 'input'
local CONFIGURE_INPUT = require 'input.configure'
local PROFILE         = require 'infra.profile'
local PLAYSFX         = require 'helpers.playsfx'
local Activity        = require 'common.activity'
local StartMenuView   = require 'view.startmenu'
local FadeView        = require 'view.fade'
local Draw            = require 'draw'
local SoundTrack      = require 'view.soundtrack'

local state = {}

--LOCAL VARIABLES--

local _menu_view
local _menu_context
local _locked
local _activity = Activity()
local _soundtrack

-- LOCAL METHODS --

function _activity:quit()
  _locked = true
  local fade_view = FadeView(FadeView.STATE_UNFADED)
  fade_view:register("GUI")
  fade_view:fadeOutAndThen(self.resume)
  self.wait()
  love.event.quit()
end

function _activity:enterMenu()
  _locked = true
  local fade_view = FadeView(FadeView.STATE_FADED)
  local menu_theme = DB.loadSpec('theme', 'main-menu')
  _soundtrack:playTheme(menu_theme)
  fade_view:register("GUI")
  fade_view:fadeInAndThen(self.resume)
  self.wait()
  _locked = false
  return fade_view:destroy()
end

function _activity:changeState(mode, to, ...)
  _locked = true
  local fade_view = FadeView(FadeView.STATE_UNFADED)
  fade_view:register("GUI")
  fade_view:fadeOutAndThen(self.resume)
  self.wait()
  fade_view:register("GUI")
  fade_view:destroy()
  if to == GS.PLAY then
    _soundtrack:clearTheme()
  end
  _menu_view.invisible = true
  return SWITCHER[mode](to, ...)
end


--STATE FUNCTIONS--
function state:enter()
  _menu_context = "START_MENU"

  _menu_view = StartMenuView()
  _menu_view:register("HUD")

  _soundtrack = SoundTrack:get()

  _activity:enterMenu()
end

function state:leave()
  _menu_view:destroy()
  _menu_view = nil
end

function state:resume(from, info)
  if from == GS.CHARACTER_BUILD and info then
    _locked = true
    _soundtrack:clearTheme()
    SWITCHER.switch(GS.PLAY, PROFILE.newRoute(info))
  else
    _menu_context = "START_MENU"
    _menu_view.invisible = false
    _activity:enterMenu()
  end
end

function state:update(dt)

  if not _locked then
    if INPUT.wasActionPressed('CONFIRM') then
      PLAYSFX 'ok-menu'
      MENU.confirm()
    elseif INPUT.wasActionPressed('SPECIAL') or
           INPUT.wasActionPressed('CANCEL') or
           INPUT.wasActionPressed('QUIT') then
      PLAYSFX 'back-menu'
      MENU.cancel()
    elseif DIRECTIONALS.wasDirectionTriggered('UP') then
      PLAYSFX 'select-menu'
      MENU.prev()
    elseif DIRECTIONALS.wasDirectionTriggered('DOWN') then
      PLAYSFX 'select-menu'
      MENU.next()
    end
  end

  if _menu_context == "START_MENU" then
    _menu_view:setItem("New route")
    _menu_view:setItem("Load route")
    _menu_view:setItem("Settings")
    if DEV then
      _menu_view:setItem("Controls")
    end
    _menu_view:setItem("Quit")
  elseif _menu_context == "LOAD_LIST" then
    local savelist = PROFILE.getSaveList()
    if next(savelist) then
      for route_id, route_header in pairs(savelist) do
        local savename = ("%s %s"):format(route_id, route_header.player_name)
        if route_header.player_dead then
          savename = savename .. " (DEAD)"
        end
        _menu_view:setItem(savename)
      end
    else
      _menu_view:setItem("[ NO DATA ]")
    end
  end

  if MENU.begin(_menu_context) then
    if _menu_context == "START_MENU" then
      if MENU.item("New route") then
        _locked = true
        _activity:changeState('push', GS.CHARACTER_BUILD)
      end
      if MENU.item("Load route") then
        _menu_context = "LOAD_LIST"
      end
      if MENU.item("Settings") then
        _activity:changeState('push', GS.SETTINGS, _soundtrack)
      end
      if DEV and MENU.item("Controls") then
        CONFIGURE_INPUT(INPUT, INPUT.getMap())
      end
      if MENU.item("Quit") then
        _activity:quit()
      end
    elseif _menu_context == "LOAD_LIST" then
      local savelist = PROFILE.getSaveList()
      if next(savelist) then
        for route_id, route_header in pairs(savelist) do
          local savename = ("%s %s"):format(route_id, route_header.player_name)
          if MENU.item(savename) then
            if not route_header.player_dead then
              local route_data = PROFILE.loadRoute(route_id)
              _activity:changeState('switch', GS.PLAY, route_data)
            else
              PLAYSFX 'denied'
            end
          end
        end
      else
        if MENU.item("[ NO DATA ]") then
          print("Cannot load no data.")
        end
      end
    end
  else
    if _menu_context == "START_MENU" then
      _activity:quit()
    elseif _menu_context == "LOAD_LIST" then
      _menu_context = "START_MENU"
    end
  end
  MENU.finish()
  _menu_view:setSelection(MENU.getSelection())
  _menu_view:update(dt)
end

function state:draw()
  Draw.allTables()
end

--Return state functions
return state
