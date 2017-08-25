
local DB = require 'database'

local spec_item = {}

--[[ Common inputs ]]-----------------------------------------------------------

function spec_item.integer(spec, key)
  return function (self) 
    local value = spec[key.id] or key.range[1]
    local changed, newvalue = imgui.InputInt(key.name, value, 1, 10)
    if changed then
      spec[key.id] = math.max(key.range[1], math.min(key.range[2], newvalue))
    end
  end
end

--[[ Enumerations ]]------------------------------------------------------------

function spec_item.enum(spec, key)
  return function(self)
    -- Build option list from given array or from a database domain
    local options = key.options
    if type(options) == 'string' then
      local domain = DB.loadDomain(options)
      options = {}
      for k,v in pairs(domain) do
        table.insert(options,k)
      end
      table.sort(options)
    end
    -- Find the index of the currently assigned option
    local current = 0
    for i,option in ipairs(options) do
      if option == spec[key.id] then
        current = i
        break
      end
    end
    -- Value getter/setter
    local function value(newvalue)
      if newvalue then
        current = newvalue
        spec[key.id] = options[newvalue]
      else
        return current
      end
    end
    imgui.InputText(key.name, spec[key.id] or "<none>", 64, { "ReadOnly" })
    if imgui.IsItemClicked() then
      self:push("list_picker", key.name, options, value)
    end
  end
end

--[[ List of elements ]]--------------------------------------------------------

function spec_item.list(spec, key)
  local data = spec[key.id]
  local list = { n = 0 }
  local selected = 0
  local function add(value)
    table.insert(list, value)
    list.n = list.n + 1
  end
  local function delete()
    data[list[selected]] = nil
    table.remove(list, selected)
    list.n = list.n - 1
  end
  for name,spec in pairs(data) do
    add(name)
  end
  return function(self)
    if imgui.Button("New " .. key.name) then
      self:push('name_input', key.name,
        function (value)
          data[value] = {}
          add(value)
        end)
    end
    imgui.Text(("All %ss:"):format(key.name))
    local changed
    changed, selected = imgui.ListBox("", selected, list, list.n, 5)
    if changed then
      local element = data[list[selected]]
      self:push('specification_editor', element, element.typename, key.name,
                delete)
    end
  end
end

--[[ Menu rendering ]]----------------------------------------------------------

return function(spec, domain_name, title, delete)

  local inputs = {}
  for _,key in DB.schemaFor(domain_name) do
    table.insert(inputs, spec_item[key.type](spec, key))
  end

  return title .. " Editor", function(self)
    imgui.PushItemWidth(120)
    for _,input in ipairs(inputs) do
      input(self)
    end
    imgui.PopItemWidth()
    imgui.Spacing()
    imgui.Indent(180)
    if imgui.Button("Delete") then
      delete()
      return true
    end
    imgui.Unindent(180)
  end

end

