
local IMGUI = require 'imgui'
local DB = require 'database'


local function add(list, specname)
  table.insert(list, specname)
  list.n = list.n + 1
end

local function sort(list)
  table.sort(list)
end

local function filter(list, filtered, search_str)
  if search_str == "" then
    return list
  else
    filtered.n = 0
    for i=1,list.n do
      if list[i]:match(search_str) then
        filtered.n = filtered.n + 1
        filtered[filtered.n] = list[i]
      end
    end
    return filtered
  end
end

return function(category_name, group_name, title)
  local group = DB.loadGroup(category_name, group_name)
  local fulllist = { n = 0 }
  local filtered = { n = 0 }
  local search_str = ""
  local list = fulllist
  local selected = 0
  for name in DB.listItemsIn(category_name, group_name) do
    add(fulllist, name)
  end
  sort(fulllist)

  local function delete()
    local specname = list[selected]
    DB.deleteGroupItem(category_name, group_name, specname)
    table.remove(list, selected)
    list.n = list.n - 1
  end

  local function newvalue(specname, spec)
    local new = spec or DB.initSpec({}, group, specname)
    for _,key in DB.schemaFor(group_name) do
      if key.type == 'list' then
        new[key.id] = new[key.id] or {}
      end
    end
    add(fulllist, specname)
    sort(fulllist)
    for i,name in DB.listItemsIn(category_name, group_name) do
      if name == specname then
        selected = i
      end
    end
  end

  local function rename(specname)
    local oldspecname = list[selected]
    local spec = DB.renameGroupItem(category_name, group_name,
                                    oldspecname, specname)
    if spec then
      delete()
      newvalue(specname, spec)
    end
  end

  return title .. " List", 1, function(gui)
    if IMGUI.Button("New "..title) then
      gui:push('name_input', title, newvalue)
    end
    local changed
    IMGUI.PushItemWidth(120)
    search_str, changed = IMGUI.InputText("Search", search_str, 32)
    IMGUI.PopItemWidth()
    IMGUI.Text(("All %ss:"):format(title))
    if changed then
      list = filter(fulllist, filtered, search_str)
    end
    selected, changed = IMGUI.ListBox("", selected, list, list.n, 15)
    if changed and selected then
      gui:push('specification_editor', group[list[selected]], group_name,
               title, delete, rename)
    end
  end

end

