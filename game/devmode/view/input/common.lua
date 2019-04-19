
local IMGUI = require 'imgui'
local class = require 'lux.class'

local max = math.max
local min = math.min
local setfenv = setfenv

local inputs = {}

local function _makeCommon(default, call)
  local InputEditor = class:new()
  function InputEditor:instance(obj, _elementspec, _fieldschema)
    setfenv(1, obj)
    function input(gui)
      if _fieldschema.name then
        IMGUI.Text(_fieldschema.name)
      end
      local value = _elementspec[_fieldschema.id] or default
      _elementspec[_fieldschema.id] = value
      IMGUI.PushID(_fieldschema.id)
      local newvalue, changed = call(value, _fieldschema)
      IMGUI.PopID()
      if changed then
        _elementspec[_fieldschema.id] = newvalue
      end
    end
    function __operator:call(gui)
      return obj.input(gui)
    end
  end
  return InputEditor
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
    local newvalue, changed = IMGUI.InputFloat("", value, 0.1, 0.5)
    if range then
      newvalue = max(range[1],
                          range[2] and min(range[2], newvalue) or newvalue)
    end
    return newvalue, changed
  end
)

inputs.integer = _makeCommon(
  0,
  function(value, field)
    value = value or (field.range or {0})[1]
    local range = field.range
    local newvalue, changed = IMGUI.InputInt("", value, 1, 10)
    if range then
      newvalue = max(range[1],
                          range[2] and min(range[2], newvalue) or newvalue)
    end
    return newvalue, changed
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
    local newvalue, changed = IMGUI.InputTextMultiline("", value, 1024)
    IMGUI.PopItemWidth()
    return newvalue, changed
  end
)

inputs.description = _makeCommon(
  "",
  function(value, field)
    IMGUI.Text(field.info)
    return "", false
  end
)

inputs.range = _makeCommon(
  0,
  function(value, field)
    assert(field.max, "No 'max' field in range input.")
    assert(field.min, "No 'min' field in range input.")
    value = max(field.min, min(field.max, value or field.min))
    local newvalue, changed = IMGUI.SliderInt("", value, field.min, field.max)
    return newvalue, changed
  end
)

return inputs
