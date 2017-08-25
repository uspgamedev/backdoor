
local DB = require 'database'

local function add(list, value)
  table.insert(list, value)
  list.n = list.n + 1
end

local function sort(list)
  table.sort(list)
end

return function(domain_name, title)

  local domain = DB.loadDomain(domain_name)
  local list = { n = 0 }
  local selected = 0
  for name,spec in pairs(domain) do
    add(list, name)
  end
  sort(list)
  local function delete()
    domain[list[selected]] = nil
    table.remove(list, selected)
    list.n = list.n - 1
  end

  return title .. " List", 1, function(self)
    if imgui.Button("New "..title) then
      self:push('name_input', title,
        function (value)
          domain[value] = {}
          add(list, value)
          sort(list)
        end)
    end
    imgui.Text(("All %ss:"):format(title))
    local changed
    changed, selected = imgui.ListBox("", selected, list, list.n, 5)
    if changed then
      self:push('specification_editor', domain[list[selected]], domain_name,
                title, delete)
    end
  end

end

