
local inputs = {}

function inputs.boolean(spec, key)
  return function (self) 
    local value = spec[key.id] or false
    local changed, newvalue = imgui.Checkbox(key.name, value)
    if changed then
      spec[key.id] = newvalue
    end
  end
end

function inputs.integer(spec, key)
  return function (self) 
    local value = spec[key.id] or key.range[1]
    local changed, newvalue = imgui.InputInt(key.name, value, 1, 10)
    if changed then
      spec[key.id] = math.max(key.range[1], math.min(key.range[2], newvalue))
    end
  end
end

return inputs

