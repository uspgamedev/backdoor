--MODULE FOR THE GAMESTATE: GAME--
local MENU = require 'infra.menu'
local INPUT = require 'infra.input'
local CONTROLS = require 'infra.control'
local HudView = require 'domain.view.hudview'

local state = {}

--LOCAL VARIABLES--

local _width, _height
local _menu_view
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
  _menu_view:addElement("HUD", nil, "menu_view")
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
  if MENU.begin("START_MENU", 80*4, _height / 2) then
    if MENU.item("New route") then
      SWITCHER.switch(GS.PLAY)
    end
    if MENU.item("Load route") then
      print("Not implemented yet")
    end
    if MENU.item("Quit") then
      love.event.quit()
    end
  else
    love.event.quit()
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
