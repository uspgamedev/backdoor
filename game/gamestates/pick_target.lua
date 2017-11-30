--MODULE FOR THE GAMESTATE: PICKING A TARGET--

local DB = require 'database'
local DIR = require 'domain.definitions.dir'
local Route = require 'domain.route'
local Sector = require 'domain.sector'
local Body = require 'domain.body'
local Actor = require 'domain.actor'
local SectorView = require 'view.sector'

local ACTION = require 'domain.action'
local CONTROL = require 'infra.control'

local GUI = require 'debug.gui'

local state = {}

--LOCAL VARIABLES--

local _is_valid_position

local _sector_view
local _cursor

local _previous_control_map

--STATE FUNCTIONS--

function state:enter(_, sector_view, target_opt)

  _sector_view = sector_view
  local i, j = unpack(target_opt.pos)
  _sector_view:newCursor(i, j, target_opt.aoe_hint, target_opt.validator,
                         target_opt.range_checker)

  local move_cursor = function (dir)
      _sector_view:moveCursor(unpack(DIR[dir]))
  end

  local confirm = function ()
    if _sector_view.cursor.validator(_sector_view:getCursorPos()) then
        local args = {
          target_is_valid = true,
          pos = {_sector_view:getCursorPos()}
        }
        SWITCHER.pop(args)
    end
  end

  local cancel = function ()
      local args = {
        target_is_valid = false,
      }
      SWITCHER.pop(args)
  end

  Signal.register("move_cursor", move_cursor)
  Signal.register("confirm", confirm)
  Signal.register("cancel", cancel)

  local signals = {
      PRESS_UP = {"move_cursor", "up"},
      PRESS_DOWN = {"move_cursor", "down"},
      PRESS_RIGHT = {"move_cursor", "right"},
      PRESS_LEFT = {"move_cursor", "left"},
      PRESS_UPLEFT = {"move_cursor", "upleft"},
      PRESS_UPRIGHT = {"move_cursor", "upright"},
      PRESS_DOWNLEFT = {"move_cursor", "downleft"},
      PRESS_DOWNRIGHT = {"move_cursor", "downright"},
      PRESS_CONFIRM = {"confirm"},
      PRESS_CANCEL = {"cancel"},
      PRESS_PAUSE = {"pause"},
  }
  for name, signal in pairs(signals) do
      signals[name] = function ()
          Signal.emit(unpack(signal))
      end
  end
  _previous_control_map = CONTROL.getMap()
  CONTROL.setMap(signals)

end

function state:leave()
    Signal.clear("move_cursor")
    Signal.clear("confirm")
    Signal.clear("cancel")

    _sector_view:removeCursor()
    CONTROL.setMap(_previous_control_map)
end

function state:update(dt)

  if not DEBUG then
    MAIN_TIMER:update(dt)
    _sector_view:lookAtCursor()
  end

  Util.destroyAll()

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

