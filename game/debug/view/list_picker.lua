
local IMGUI = require 'imgui'

return function(name, list, value)

  return "Choose a " .. name, 1, function(self)
    IMGUI.Text("Options:")
    IMGUI.PushItemWidth(160)
    local changed, newvalue = IMGUI.ListBox("", value(), list, #list, 5)
    local confirmed
    if changed then
      confirmed = value(newvalue)
    end
    IMGUI.PopItemWidth()
    if confirmed then return true end
  end

end

