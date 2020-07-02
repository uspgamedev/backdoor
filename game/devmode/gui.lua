
-- luacheck: globals love DEBUG

local IMGUI   = require 'imgui'
local DB      = require 'database'
local tween   = require 'helpers.tween'
local Class   = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"

local MENU_WIDTH = 240
local MENU_MAX_HEIGHT = 600

local GUI = Class {
  __includes = { ELEMENT }
}

local DOMAINS = {
  'body', 'actor', 'appearance', 'sector',
  'card', 'cardset', 'collection',
  'drop', 'faction', 'zone', 'theme',
  body = "Body Type",
  actor = "Actor Type",
  appearance = "Appearance",
  sector = "Sector Type",
  card = "Card",
  cardset = "Card Set",
  collection = "Collection",
  drop = "Drop",
  faction = "Faction",
  theme = "Theme",
  zone = "Zone",
}

local RESOURCES = {
  'font', 'texture', 'sprite', 'tileset', 'sfx', 'bgm',
  font = "Font",
  texture = "Texture",
  sfx = "Sound Effect",
  bgm = "Background Music",
  sprite = "Animated Sprite",
  tileset = "TileSet",
}


local _VIEW = {}

-- This automatically loads all devmode menus in debug/view
for _,file in ipairs(love.filesystem.getDirectoryItems "devmode/view") do
  if file:match "^.+%.lua$" then
    file = file:gsub("%.lua", "")
    _VIEW[file] = require('devmode.view.' .. file)
  end
end

function GUI:init()

  ELEMENT.init(self)
  self.exception = true
  self.stack = {}
  self.active = false
  self.current_level = 1
  self.demo_window = false

  IMGUI.StyleColorsDark()
  IMGUI.SetGlobalFontFromFileTTF("assets/font/PTMono-Regular.ttf", 18)

end

function GUI:length()
  local length = 0
  for _,view in ipairs(self.stack) do
    length = length + view.size
  end
  return length
end

--- Pushes a menu. Menus in devmode mode appear from left to right and behave
--  like a stack. It's easier to understand if you play and check it out.
function GUI:push(viewname, ...)
  local level = self.current_level+1
  self:pop(level)
  local title, size, render = _VIEW[viewname](...)
  local length = self:length()
  local width = MENU_WIDTH * size
  local x = tween.start(
    (length-size)*MENU_WIDTH,
    8 + length*MENU_WIDTH + #self.stack * 8,
    5
  )
  self.stack[level] = {
    size = size,
    draw = function (view)
      IMGUI.SetNextWindowPos(x(), 40, "Always")
      IMGUI.SetNextWindowSizeConstraints(width, 80, width, MENU_MAX_HEIGHT)
      IMGUI.PushStyleVar("WindowPadding", 16, 16)
      local open = IMGUI.Begin(title, true,
                                 { "NoCollapse", "AlwaysAutoResize",
                                 "AlwaysUseWindowPadding" })
      if open then
        open = not render(view)
      end
      IMGUI.End()
      IMGUI.PopStyleVar()
      return open
    end
  }
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

  IMGUI.NewFrame()
  IMGUI.PushStyleVar('FramePadding', 8, 4)

  if IMGUI.BeginMainMenuBar() then
    if IMGUI.BeginMenu("Route") then
      if IMGUI.MenuItem("Bodies") then
        self:push('bodies_menu')
      end
      IMGUI.EndMenu()
    end
    if IMGUI.BeginMenu("Domains") then
      for _,name in ipairs(DOMAINS) do
        local title = DOMAINS[name]
        if IMGUI.MenuItem(title.."s") then
          self:push("category_list", 'domains', name, title)
        end
      end
      IMGUI.Separator()
      if IMGUI.MenuItem("Refresh") then
        DB.refresh(DB.loadCategory('domains'))
      end
      if IMGUI.MenuItem("Save") then
        DB.save(DB.loadCategory('domains'))
      end
      IMGUI.EndMenu()
    end
    if IMGUI.BeginMenu("Resources") then
      for _,name in ipairs(RESOURCES) do
        local title = RESOURCES[name]
        if IMGUI.MenuItem(title.."s") then
          self:push("category_list", 'resources', name, title)
        end
      end
      IMGUI.Separator()
      if IMGUI.MenuItem("Refresh") then
        DB.refresh(DB.loadCategory('resources'))
      end
      if IMGUI.MenuItem("Save") then
        DB.save(DB.loadCategory('resources'))
      end
      IMGUI.EndMenu()
    end
    if IMGUI.BeginMenu("IMGUI") then
      if IMGUI.MenuItem("Demo Window") then
        self.demo_window = true
      end
      IMGUI.EndMenu()
    end
    IMGUI.EndMainMenuBar()
  end

  for level,view in ipairs(self.stack) do
    self.current_level = level
    if not view.draw(self) then
      if level > 0 then
        self:pop(level)
        break
      end
    end
  end

  if self.demo_window then
    self.demo_window = IMGUI.ShowDemoWindow(self.demo_window)
  end

  g.setBackgroundColor(50/255, 80/255, 80/255, 1)
  g.setColor(1, 1, 1)
  IMGUI.PopStyleVar(1)
  IMGUI.Render()
end

return GUI
