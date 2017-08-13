
local DB = require 'database'
local tween = require 'helpers.tween'

local MENU_WIDTH = 240

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
  local x = tween.start((level-2)*MENU_WIDTH, (level-1)*(MENU_WIDTH+8), 5)
  self.stack[level] = function (self)
    imgui.SetNextWindowPos(x(), MENU_WIDTH, "Always")
    imgui.SetNextWindowSizeConstraints(MENU_WIDTH, 80, MENU_WIDTH, 400)
    local _,open = imgui.Begin(viewname, true,
                               { "NoCollapse", "AlwaysAutoResize" })
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
  local selected = nil
  local menus = {
    "Game", "Current Route", "Database"
  }
  return function(self)
    for _,menu in ipairs(menus) do
      if imgui.Selectable(menu, menu == selected) then
        selected = menu
        self:push(menu)
      end
    end
  end
end

view["Game"] = function()
  return function(self)
    imgui.Text("Not yet implemented ;)")
  end
end

view["Current Route"] = function()
  local selected = nil
  return function(self)
    for actor,_ in pairs(Util.findSubtype 'actor') do
      if imgui.Selectable(actor:getId(), actor == selected) then
        selected = actor
        self:push("Actor", actor)
      end
    end
  end
end

view["Actor"] = function (actor)
  local edit_hp
  return function(self)
    imgui.Text(("ID: %s"):format(actor:getId()))
    local hp = actor:getBody():getHP()
    imgui.PushItemWidth(100)
    local _, newhp = imgui.SliderInt("Hit Points", hp, 1,
                                     actor:getBody():getMaxHP())
    imgui.PopItemWidth()
    actor:getBody():setHP(newhp)
  end
end

view["Database"] = function()
  local domains = {
    'body', 'actor',
    body = "Body Types",
    actor = "Actor Types"
  }
  local selected = nil
  return function(self)
    for _,name in ipairs(domains) do
      local title = domains[name]
      if imgui.Selectable(title, selected == name) then
        selected = name
        self:push("Domain List", selected)
      end
    end
    imgui.Spacing()
    if imgui.Button("Save", 224, 24) then
      DB.save()
    end
  end
end

view["Domain List"] = function(domain_name)
  local selected = nil
  return function(self)
    for name,spec in pairs(DB.loadDomain(domain_name)) do
      if imgui.Selectable(name, selected == name) then
        selected = name
        self:push("Specification", spec, domain_name)
      end
    end
  end
end

view["Specification"] = function(spec, domain_name)
  return function(self)
    imgui.Text("Wait for it...")
    for _,key in DB.schemaFor(domain_name) do
      if key.type == 'enum' then
        local options = key.options
        if type(options) == 'string' then
          local domain = DB.loadDomain(options)
          options = {}
          for k,v in pairs(domain) do
            table.insert(options,k)
          end
        end
        local current = 0
        for i,option in ipairs(options) do
          if option == spec[key.id] then
            current = i
            break
          end
        end
        local function value(newvalue)
          if newvalue then
            current = newvalue
            spec[key.id] = options[newvalue]
          else
            return current
          end
        end
        if imgui.Button(("Change##%s"):format(key.id)) then
          print("change")
          self:push("Choose One", key.name, options, value)
        end
        imgui.SameLine()
        imgui.PushItemWidth(100)
        imgui.InputText(key.name, spec[key.id] or "<none>", 64, { "ReadOnly" })
        imgui.PopItemWidth()
      elseif key.type == 'integer' then
        imgui.PushItemWidth(160)
        local value = spec[key.id]
        local _, newvalue = imgui.InputInt(key.name, value, 1, 10)
        spec[key.id] = newvalue
        imgui.PopItemWidth()
      end
    end
  end
end

view["Choose One"] = function(name, list, value)
  return function(self)
    imgui.Text(("Choose a %s:"):format(name))
    imgui.PushItemWidth(160)
    local changed, newvalue = imgui.ListBox("", value(), list, #list)
    if changed then
      value(newvalue)
    end
    imgui.PopItemWidth()
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

