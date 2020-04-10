
-- luacheck: globals imgui DEBUG SWITCHER, no self

local Draw  = require "draw"
local INPUT = require 'input'

local state = {}

function state:update(_)
  if INPUT.wasActionPressed('DEVMODE') and DEBUG then
    DEBUG = false
    return SWITCHER.pop()
  end
end

function state:draw()
  Draw.allTables()
end

function state:keypressed(key)
  imgui.KeyPressed(key)
end

function state:textinput(t)
  imgui.TextInput(t)
end

function state:keyreleased(key)
  imgui.KeyReleased(key)
end

function state:mousemoved(x, y)
  imgui.MouseMoved(x, y)
end

function state:mousepressed(_, _, button)
  imgui.MousePressed(button)
end

function state:mousereleased(_, _, button)
  imgui.MouseReleased(button)
end

function state:wheelmoved(_, y)
  imgui.WheelMoved(y)
end

return state

