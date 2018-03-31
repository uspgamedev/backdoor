
local IMGUI = require 'imgui'

return function(title, validator)

  local name = ""

  return "Name for " .. title, 1, function(gui)
    local changed
    name, changed = IMGUI.InputText("", name, 64)
    if (IMGUI.Button("Confirm") or IMGUI.IsKeyPressed(12))
        and name ~= "" then
      validator(name)
      return true
    end
  end
  
end

