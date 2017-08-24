--MODULE FOR THE GAMESTATE: GAME--
local MENU = require 'infra.menu'
local INPUT = require 'infra.input'
local CONTROLS = require 'infra.control'
local HudView = require 'domain.view.hudview'

local state = {}

--LOCAL VARIABLES--

local _width, _height
local _menu_view

--LOCAL FUNCTIONS--

local function _sendToLayer ()
  local render_queue = MENU.getRenderQueue()
  while not render_queue.isEmpty() do
    local printing = render_queue.pop()
    _menu_view:push(printing)
  end
end

--STATE FUNCTIONS--

function state:init ()
  _menu_view = HudView()
  _width, _height = love.window.getMode()
end

function state:enter ()
  _menu_view:addElement("HUD", nil, "menu_view")
  print(Util.findId("menu_view"))
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
  if MENU.begin("START_MENU", _width / 2 - 160, _height / 2, false, 320) then
    if MENU.item("NEW ROUTE") then
      SWITCHER.switch(GS.PLAY)
    end
    if MENU.item("LOAD ROUTE") then
      print("Not implemented yet")
    end
    if MENU.item("QUIT") then
      love.event.quit()
    end
  else
    love.event.quit()
  end
  MENU.finish()
  _sendToLayer()
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
