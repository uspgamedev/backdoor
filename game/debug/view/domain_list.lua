
local DB = require 'database'

return function(domain_name, title)

  local domain = DB.loadDomain(domain_name)
  local list = { n = 0 }
  local selected = 0
  for name,spec in pairs(domain) do
    table.insert(list, name)
    list.n = list.n + 1
  end

  return title .. " List", function(self)
    if imgui.Button("New "..title) then
      self:push('name_input', title,
        function (value)
          domain[value] = {}
          table.insert(list, 1, value)
          list.n = list.n + 1
        end)
    end
    imgui.Text(("All %ss:"):format(title))
    local changed
    changed, selected = imgui.ListBox("", selected, list, list.n, 5)
    if changed then
      self:push('specification_editor', domain[list[selected]], domain_name,
                title)
    end
  end

end

