
return function(name, list, value)

  return "Choose a " .. name, 1, function(self)
    imgui.Text("Options:")
    imgui.PushItemWidth(160)
    local changed, newvalue = imgui.ListBox("", value(), list, #list, 5)
    local confirmed
    if changed then
      confirmed = value(newvalue)
    end
    imgui.PopItemWidth()
    if confirmed then return true end
  end

end

