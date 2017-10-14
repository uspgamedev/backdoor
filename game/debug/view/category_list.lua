
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

return function(category_name, group_name, title)
  local group = DB.loadGroup(category_name, group_name)
  local list = { n = 0 }
  local selected = 0
  for name in DB.listItemsIn(category_name, group_name) do
    add(list, name)
  end
  sort(list)

  local function delete()
    local item_name = list[selected]
    group[item_name] = DEFS.DELETE
    table.remove(list, selected)
    list.n = list.n - 1
  end

  local function newvalue(value, spec)
    local new = spec or DB.initSpec({}, group, value)
    for _,key in DB.schemaFor(group_name) do
      if key.type == 'list' then
        new[key.id] = new[key.id] or {}
      end
    end
    group[value] = new
    add(list, value)
    sort(list)
    for i,name in DB.listItemsIn(category_name, group_name) do
      if name == value then
        selected = i
      end
    end
  end

  local function rename(value)
    local spec = group[list[selected]]
    local meta = getmetatable(spec)
    meta.relpath = meta.relpath:gsub(meta.group, value)
    meta.group = value
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
      self:push('specification_editor', group[list[selected]], group_name,
                title, delete, rename)
    end
  end

end

