
local IMGUI = require 'imgui'

local inputs = {}

local function _makeCommon(default, call)
  return function(spec, field)
    return function(self)
      if field.name then
        IMGUI.Text(field.name)
      end
      local value = spec[field.id] or default
      spec[field.id] = value
      IMGUI.PushID(field.id)
      local changed, newvalue = call(value, field)
      IMGUI.PopID()
      if changed then
        spec[field.id] = newvalue
      end
    end
  end
end

inputs.boolean = _makeCommon(
  false,
  function(value, field)
    return IMGUI.Checkbox("", value)
  end
)

inputs.float = _makeCommon(
  nil,
  function(value, field)
    value = value or field.default or (field.range or {0})[1]
    local range = field.range
    local changed, newvalue = IMGUI.InputFloat("", value, 0.1, 0.5)
    if range then
      newvalue = math.max(range[1],
                          range[2] and math.min(range[2], newvalue) or newvalue)
    end
    return changed, newvalue
  end
)

inputs.integer = _makeCommon(
  0,
  function(value, field)
    value = value or (field.range or {0})[1]
    local range = field.range
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
  function(value, field)
    return IMGUI.InputText("", value, 64)
  end
)

inputs.text = _makeCommon(
  "",
  function(value, field)
    IMGUI.PushItemWidth(360)
    local changed, newvalue = IMGUI.InputTextMultiline("", value, 1024)
    IMGUI.PopItemWidth()
    return changed, newvalue
  end
)

inputs.description = _makeCommon(
  "",
  function(value, field)
    IMGUI.Text(field.info)
    return false
  end
)

return inputs
