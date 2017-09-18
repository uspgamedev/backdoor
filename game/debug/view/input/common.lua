
local IMGUI = require 'imgui'

local inputs = {}

function inputs.boolean(spec, key)
  return function (self)
    IMGUI.Text(key.name)
    local value = spec[key.id] or false
    IMGUI.PushID(key.id)
    local changed, newvalue = IMGUI.Checkbox("", value)
    IMGUI.PopID()
    if changed then
      spec[key.id] = newvalue
    end
  end
end

function inputs.integer(spec, key)
  local inputInt = require 'debug.view.helpers.integer'
  return function (self)
    IMGUI.Text(key.name)
    local value = spec[key.id] or (key.range or {0})[1]
    IMGUI.PushID(key.id)
    local changed, newvalue = inputInt(value, "", range)
    IMGUI.PopID()
    if changed then
      spec[key.id] = newvalue
    end
  end
end

function inputs.string(spec, key)
  local inputStr = require 'debug.view.helpers.string'
  return function (self)
    IMGUI.Text(key.name)
    local value = spec[key.id] or ""
    IMGUI.PushID(key.id)
    local changed, newvalue = inputStr(value, "")
    IMGUI.PopID()
    if changed then
      spec[key.id] = newvalue
    end
  end
end

function inputs.text(spec, key)
  return function (self)
    IMGUI.Text(key.name)
    local value = spec[key.id] or ""
    IMGUI.PushID(key.id)
    local changed, newvalue = IMGUI.InputTextMultiline("", value, 256,
                                                       208,100)
    IMGUI.PopID()
    if changed then
      spec[key.id] = newvalue
    end
  end
end

return inputs
