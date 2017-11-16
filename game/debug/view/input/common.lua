
local IMGUI = require 'imgui'

local inputs = {}

local function _makeCommon(default, call)
  return function(spec, key)
    return function(self)
      if key.name then
        IMGUI.Text(key.name)
      end
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
    value = value or (key.range or {0})[1]
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
    IMGUI.PushItemWidth(360)
    local changed, newvalue = IMGUI.InputTextMultiline("", value, 256)
    IMGUI.PopItemWidth()
    return changed, newvalue
  end
)

inputs.description = _makeCommon(
  "",
  function(value, key)
    IMGUI.Text(key.info)
    return false
  end
)

return inputs

