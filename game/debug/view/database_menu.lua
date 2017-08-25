
local DB = require 'database'

return function()

  local domains = {
    'body', 'actor', 'sector',
    body = "Body Type",
    actor = "Actor Type",
    sector = "Sector Type"
  }

  local selected = nil
  
  return "Database Menu", function(self)
    for _,name in ipairs(domains) do
      local title = domains[name]
      if imgui.Selectable(title.."s", selected == name) then
        selected = name
        self:push("domain_list", selected, title)
      end
    end
    imgui.Spacing()
    imgui.Indent(180)
    if imgui.Button("Save") then
      DB.save()
    end
    imgui.Unindent(180)
  end

end

