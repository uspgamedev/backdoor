
return function(title, validator)

  local name = ""

  return "Name for " .. title, 1, function(self)
    local changed
    changed, name = imgui.InputText("", name, 64)
    if (imgui.Button("Confirm") or imgui.IsKeyPressed(12))
        and name ~= "" then
      validator(name)
      return true
    end
  end
  
end

