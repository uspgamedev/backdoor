
return function(name, list, value)

  return "Choose a " .. name, function(self)
    imgui.Text("Options:")
    imgui.PushItemWidth(160)
    local changed, newvalue = imgui.ListBox("", value(), list, #list, 5)
    if changed then
      value(newvalue)
    end
    imgui.PopItemWidth()
  end

end

