
local IMGUI = require 'imgui'
local DB = require 'database'
local DEFS = require 'domain.definitions'

local function add(list, value)
  table.insert(list, value)
  list.n = list.n + 1
end

local function sort(list)
  table.sort(list)
end

return function(resource_name, title)
  local resource = DB.loadResourceGroup(resource_name)
  print(resource_name, resource)
  local list = { n = 0 }
  local selected = 0
  for name in DB.listResourceItems(resource_name) do
    add(list, name)
  end
  sort(list)

  local function delete()
    local item_name = list[selected]
    resource[item_name] = DEFS.DELETE
    table.remove(list, selected)
    list.n = list.n - 1
  end

  local function newvalue(value, spec)
    local new = spec or DB.initSpec({}, resource)
    for _,key in DB.schemaFor(resource_name) do
      if key.type == 'list' then
        new[key.id] = new[key.id] or {}
      end
    end
    resource[value] = new
    add(list, value)
    sort(list)
    for i,name in DB.listResourceItems(resource_name) do
      if name == value then
        selected = i
      end
    end
  end

  local function rename(value)
    local spec = resource[list[selected]]
    if spec then
      delete()
      newvalue(value, spec)
    end
  end

  return title .. " List", 1, function(self)
    if IMGUI.Button("New "..title) then
      self:push('name_input', title, newvalue)
    end
    IMGUI.Text(("All %ss:"):format(title))
    local changed
    changed, selected = IMGUI.ListBox("", selected, list, list.n, 15)
    if changed then
      self:push('specification_editor', resource[list[selected]], resource_name,
                title, delete, rename)
    end
  end

end

