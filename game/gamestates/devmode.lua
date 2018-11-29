local Draw  = require "draw"


local state = {}

function state:update(dt)
  if not DEBUG then
    SWITCHER.pop()
  end
end

function state:draw()
  Draw.allTables()
end

function state:keypressed(key)
  imgui.KeyPressed(key)
  if not imgui.GetWantCaptureKeyboard() and key == 'f1' then
    DEBUG = false
  end
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

function state:mousepressed(x, y, button)
  imgui.MousePressed(button)
end

function state:mousereleased(x, y, button)
  imgui.MouseReleased(button)
end

function state:wheelmoved(x, y)
  imgui.WheelMoved(y)
end

return state
