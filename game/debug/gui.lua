
local tween = require 'helpers.tween'

local GUI = Class {
  __includes = { ELEMENT }
}

local view = {}

function GUI:init()

  ELEMENT.init(self)
  self.stack = {}
  self.active = false
  self.current_level = 1

end

function GUI:push(viewname, ...)
  local level = self.current_level+1
  self:pop(level)
  local render = view[viewname](...)
  local x = tween.start((level-2)*200, (level-1)*200, 5)
  self.stack[level] = function (self)
    imgui.SetNextWindowPos(x(), 200, "Always")
    imgui.SetNextWindowSizeConstraints(200, 100, 200, 400)
    local _,open = imgui.Begin(viewname, true, { "NoCollapse" })
    if open then
      render(self)
    end
    imgui.End()
    return open
  end
end

function GUI:pop(level)
  for i=level,#self.stack do
    self.stack[i] = nil
  end
end

view["Debug Menu"] = function()
  return function(self)
    for actor,_ in pairs(Util.findSubtype 'actor') do
      if imgui.Button(actor.id) then
        self:push("Actor", actor)
      end
    end
  end
end

view["Actor"] = function (actor)
  return function(self)
    imgui.Text(("ID: %s"):format(actor.id))
    imgui.Text(("HP: %d"):format(actor:getBody():getHP()))
  end
end


function GUI:draw()
  if DEBUG and not self.active then
    self.current_level = 0
    self:push("Debug Menu")
    self.active = true
  elseif not DEBUG then
    self.stack = {}
    self.active = false
    return
  end

  local g = love.graphics

  imgui.NewFrame()

  for level,view in ipairs(self.stack) do
    self.current_level = level
    if not view(self) then
      if level > 1 then
        self:pop(level)
        break
      end
    end
  end

  g.setBackgroundColor(50, 80, 80, 255)
  g.setColor(255, 255, 255)
  imgui.Render()
end

return GUI

