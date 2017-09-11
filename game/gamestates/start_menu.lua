--MODULE FOR THE GAMESTATE: MAIN MENU--
local MENU = require 'infra.menu'
local CONTROLS = require 'infra.control'
local PROFILE = require 'infra.profile'
local HudView = require 'domain.view.hudview'

local state = {}

--LOCAL VARIABLES--

local _width, _height
local _menu_view
local _menu_context
local _font
local _mapping

--LOCAL FUNCTIONS--

local function _title()
  _menu_view:push {"setFont", _font}
  _menu_view:push {"setColor", 0xff, 0xff, 0xff, 0xff}
  _menu_view:push {"print", "backdoor", 80*4, _height/4}
end

--STATE FUNCTIONS--

function state:init()
  local g = love.graphics
  _menu_view = HudView()
  _font = g.newFont(48)
  _width, _height = g.getDimensions()
  _mapping = {
    PRESS_CONFIRM  = MENU.confirm,
    PRESS_SPECIAL  = MENU.cancel,
    PRESS_CANCEL   = MENU.cancel,
    PRESS_QUIT     = MENU.cancel,
    PRESS_UP       = MENU.prev,
    PRESS_DOWN     = MENU.next,
  }
end

function state:enter()
  love.graphics.setBackgroundColor(0, 0, 0)
  _menu_view:addElement("HUD", nil, "menu_view")
  _menu_context = "START_MENU"
  CONTROLS.setMap(_mapping)
end

function state:leave()
  _menu_view:destroy()
end

function state:resume(from, player_info)
  if player_info then
    local route_data = PROFILE.newRoute()
    local actor_ref = route_data.sectors[1].actors[1]
    local body_ref = route_data.sectors[1].bodies[1]

    -- FIXME: ALL PLAYER BACKGROUNDS HAVE THE SAME ACTIONS
    -- suggestion: have the primary action be registered in the DB
    local bg = player_info.background
    actor_ref.specname = bg.title

    local race = player_info.race
    body_ref.specname = race.title

    print(string.format("selected %s %s", bg.title, race.title))
    SWITCHER.switch(GS.PLAY, route_data)
  else
    _menu_view:addElement("HUD", nil, "menu_view")
    _menu_context = "START_MENU"
    CONTROLS.setMap(_mapping)
  end
end

function state:update(dt)
  if MENU.begin(_menu_context, 80*4, _height / 2, 3, 160) then
    if _menu_context == "START_MENU" then
      if MENU.item("New route") then
        _menu_view:destroy()
        SWITCHER.push(GS.CHARACTER_BUILD)
      end
      if MENU.item("Load route") then
        _menu_context = "LOAD_LIST"
      end
      if MENU.item("Quit") then
        love.event.quit()
      end
    elseif _menu_context == "LOAD_LIST" then
      local savelist = PROFILE.getSaveList()
      if next(savelist) then
        for route_id, route_header in pairs(savelist) do
          if MENU.item(route_header.player_name .. route_id) then
            SWITCHER.switch(GS.PLAY, PROFILE.loadRoute(route_id))
          end
        end
      else
        if MENU.item("[ NO DATA ]") then
          _menu_context = "START_MENU"
        end
      end
    end
  else
    if _menu_context == "START_MENU" then
      love.event.quit()
    elseif _menu_context == "LOAD_LIST" then
      _menu_context = "START_MENU"
    end
  end
  MENU.finish()
  _title()
  MENU.flush(_menu_view)
end

function state:draw()
  Draw.allTables()
end

function state:getView()
  return _menu_view
end

--Return state functions
return state
