
local IMGUI = require 'imgui'

return function(name, list, value)

  return "Choose a " .. name, 1, function(gui)
    IMGUI.Text("Options:")
    IMGUI.PushItemWidth(160)
    local newvalue, changed = IMGUI.ListBox("", value(), list, #list, 15)
    local confirmed
    if changed then
      confirmed = value(newvalue)
    end
    IMGUI.PopItemWidth()
    if confirmed then return true end
  end

end

