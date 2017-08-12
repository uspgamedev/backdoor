
local tween = require 'helpers.tween'

local GUI = Class {
  __includes = { ELEMENT }
}

local view = {}

function GUI:init()

  ELEMENT.init(self)
  self.stack = {}
  self.active = false

end

function GUI:push(level, viewname, ...)
  for i=level,#self.stack do
    self.stack[i] = nil
  end
  self.stack[level] = view[viewname](level, ...)
end

function view.main(level)
  local x = tween.start((level-2)*200, (level-1)*200, 5)
  return function(self)
    imgui.SetNextWindowPos(x(), 200, "Always")
    imgui.SetNextWindowSizeConstraints(200, 10, 200, 400)
    imgui.Begin("Actors", true, { "NoCollapse" })
    for actor,_ in pairs(Util.findSubtype 'actor') do
      if imgui.Button(actor.id) then
        self:push(level+1, 'actor', actor)
      end
    end
    imgui.End()
  end
end

function view.actor(level, actor)
  local x = tween.start((level-2)*200, (level-1)*200, 5)
  return function(self)
    imgui.SetNextWindowPos(x(), 200, "Always")
    imgui.SetNextWindowSizeConstraints(200, 10, 200, 400)
    imgui.Begin(actor.id, false, { "NoCollapse" })
    imgui.Text(("HP: %d"):format(actor:getBody():getHP()))
    imgui.End()
  end
end


function GUI:draw()
  if DEBUG and not self.active then
    self:push(1, 'main')
    self.active = true
  elseif not DEBUG then
    self.stack = {}
    self.active = false
    return
  end

  local g = love.graphics

  imgui.NewFrame()

  for _,view in ipairs(self.stack) do
    view(self)
  end

  g.setBackgroundColor(50, 80, 80, 255)
  g.setColor(255, 255, 255)
  imgui.Render()
end

return GUI
