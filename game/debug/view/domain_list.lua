
local DB = require 'database'

return function(domain_name, title)

  local selected = nil

  return title .. " List", function(self)
    for name,spec in pairs(DB.loadDomain(domain_name)) do
      if imgui.Selectable(name, selected == name) then
        selected = name
        self:push("specification_editor", spec, domain_name, title)
      end
    end
  end

end

