
return function(title, validator)

  local name = ""

  return "Name for " .. title, function(self)
    local changed
    changed, name = imgui.InputText("", name, 64)
    if imgui.Button("Confirm") and name ~= "" then
      validator(name)
      return true
    end
  end
  
end

