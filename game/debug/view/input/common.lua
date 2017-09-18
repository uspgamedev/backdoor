
local IMGUI = require 'imgui'

local inputs = {}

local function _makeCommon(default, call)
  return function(spec, key)
    return function(self)
      IMGUI.Text(key.name)
      local value = spec[key.id] or default
      IMGUI.PushID(key.id)
      local changed, newvalue = call(value, key)
      IMGUI.PopID()
      if changed then
        spec[key.id] = newvalue
      end
    end
  end
end

inputs.boolean = _makeCommon(
  false,
  function(value, key)
    return IMGUI.Checkbox("", value)
  end
)

inputs.integer = _makeCommon(
  nil,
  function(value, key)
    local range = key.range
    local changed, newvalue = IMGUI.InputInt("", value, 1, 10)
    if range then
      newvalue = math.max(range[1],
                          range[2] and math.min(range[2], newvalue) or newvalue)
    end
    return changed, newvalue
  end
)

inputs.string = _makeCommon(
  "",
  function(value, key)
    return IMGUI.InputText("", value, 64)
  end
)

inputs.text = _makeCommon(
  "",
  function(value, key)
    return IMGUI.InputTextMultiline("", value, 256)
  end
)

return inputs

