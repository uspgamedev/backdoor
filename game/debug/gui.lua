
local DB = require 'database'
local tween = require 'helpers.tween'

local MENU_WIDTH = 240

local GUI = Class {
  __includes = { ELEMENT }
}

local DOMAINS = {
  'body', 'actor', 'sector',
  body = "Body Type",
  actor = "Actor Type",
  sector = "Sector Type"
}

local view = {}

-- This automatically loads all debug menus in debug/view
for _,file in ipairs(love.filesystem.getDirectoryItems "debug/view") do
  if file:match "^.+%.lua$" then
    file = file:gsub("%.lua", "")
    view[file] = require('debug.view.' .. file)
  end
end

function GUI:init(sector_view)

  ELEMENT.init(self)
  self.stack = {}
  self.active = false
  self.current_level = 1
  self.sector_view = sector_view

end

--- Pushes a menu. Menus in debug mode appear from left to right and behave like
--  a stack. It's easier to understand if you play and check it out.
function GUI:push(viewname, ...)
  local level = self.current_level+1
  self:pop(level)
  local title, render = view[viewname](...)
  local x = tween.start((level-2)*MENU_WIDTH, (level-1)*(MENU_WIDTH+8), 5)
  self.stack[level] = function (self)
    imgui.SetNextWindowPos(x(), MENU_WIDTH, "Always")
    imgui.SetNextWindowSizeConstraints(MENU_WIDTH, 80, MENU_WIDTH, 400)
    local _,open = imgui.Begin(title, true,
                               { "NoCollapse", "AlwaysAutoResize" })
    if open then
      open = not render(self)
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

function GUI:draw()
  if DEBUG and not self.active then
    self.active = true
  elseif not DEBUG then
    self.stack = {}
    self.active = false
    return
  end

  self.current_level = 0

  local g = love.graphics

  imgui.NewFrame()

  if imgui.BeginMainMenuBar() then
    if imgui.BeginMenu("Game") then
      imgui.Text("WIP")
      if imgui.MenuItem("New Game") then
      end
      if imgui.MenuItem("Save & Quit") then
      end
      if imgui.MenuItem("Load") then
      end
      imgui.EndMenu()
    end
    if imgui.BeginMenu("Current Route") then
      if imgui.MenuItem("Actors") then
        self:push('actors_menu')
      end
      imgui.EndMenu()
    end
    if imgui.BeginMenu("Database") then
      for _,name in ipairs(DOMAINS) do
        local title = DOMAINS[name]
        if imgui.MenuItem(title.."s") then
          self:push("domain_list", name, title)
        end
      end
      if imgui.MenuItem("Save") then
        DB.save()
      end
      imgui.EndMenu()
    end
    imgui.EndMainMenuBar()
  end

  for level,view in ipairs(self.stack) do
    self.current_level = level
    if not view(self) then
      if level > 0 then
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

