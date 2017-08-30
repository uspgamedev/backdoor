--MODULE FOR THE GAMESTATE: GAME--
local MENU = require 'infra.menu'
local INPUT = require 'infra.input'
local CONTROLS = require 'infra.control'
local PROFILE = require 'infra.profile'
local HudView = require 'domain.view.hudview'

local state = {}

--LOCAL VARIABLES--

local _width, _height
local _menu_view
local _menu_context
local _font

--LOCAL FUNCTIONS--

local function _title ()
  _menu_view:push { "setFont", _font }
  _menu_view:push { "setColor", 0xff, 0xff, 0xff, 0xff }
  _menu_view:push { "print", "backdoor", 80*4, _height/4 }
end

--STATE FUNCTIONS--

function state:init ()
  _menu_view = HudView()
  _font = love.graphics.newFont(48)
  _width, _height = love.window.getMode()
end

function state:enter ()
  love.graphics.setBackgroundColor(0, 0, 0)
  _menu_view:addElement("HUD", nil, "menu_view")
  _menu_context = "START_MENU"
  CONTROLS.setMap {
    PRESS_ACTION_1 = MENU.confirm,
    PRESS_SPECIAL  = MENU.cancel,
    PRESS_CANCEL   = MENU.cancel,
    PRESS_QUIT     = MENU.cancel,
    PRESS_UP       = MENU.prev,
    PRESS_DOWN     = MENU.next,
  }
end

function state:leave ()
  _menu_view:destroy()
end

function state:update (dt)
  INPUT.update()
  if MENU.begin(_menu_context, 80*4, _height / 2, 3, 160) then
    if _menu_context == "START_MENU" then
      if MENU.item("New route") then
        local route_data = PROFILE.newRoute()
        SWITCHER.switch(GS.PLAY, route_data)
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
          if MENU.item(route_header.charname .. route_id) then
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

function state:draw ()
  Draw.allTables()
end

function state:keypressed(key)
  INPUT.key_pressed(key)
end

function state:keyreleased(key)
  INPUT.key_released(key)
end

function state:getView ()
  return _menu_view
end

--Return state functions
return state
