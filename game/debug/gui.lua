
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
  for i=level,#self.stack do
    self.stack[i] = nil
  end
  local render = view[viewname](...)
  local x = tween.start((level-2)*200, (level-1)*200, 5)
  self.stack[level] = function (self)
    imgui.SetNextWindowPos(x(), 200, "Always")
    imgui.SetNextWindowSizeConstraints(200, 10, 200, 400)
    render(self)
  end
end

function view.main()
  return function(self)
    imgui.Begin("Actors", true, { "NoCollapse" })
    for actor,_ in pairs(Util.findSubtype 'actor') do
      if imgui.Button(actor.id) then
        self:push('actor', actor)
      end
    end
    imgui.End()
  end
end

function view.actor(actor)
  return function(self)
    imgui.Begin(actor.id, false, { "NoCollapse" })
    imgui.Text(("HP: %d"):format(actor:getBody():getHP()))
    imgui.End()
  end
end


function GUI:draw()
  if DEBUG and not self.active then
    self.current_level = 0
    self:push('main')
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
    view(self)
  end

  g.setBackgroundColor(50, 80, 80, 255)
  g.setColor(255, 255, 255)
  imgui.Render()
end

return GUI
