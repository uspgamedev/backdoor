
local IMGUI = require 'imgui'

local inputs = {}

function inputs.boolean(spec, key)
  return function (self)
    local value = spec[key.id] or false
    local changed, newvalue = IMGUI.Checkbox(key.name, value)
    if changed then
      spec[key.id] = newvalue
    end
  end
end

function inputs.integer(spec, key)
  local inputInt = require 'debug.view.helpers.integer'
  return function (self)
    local value = spec[key.id] or (key.range or {0})[1]
    spec[key.id] = inputInt(value, key.name, range)
  end
end

function inputs.string(spec, key)
  local inputStr = require 'debug.view.helpers.string'
  return function (self)
    local value = spec[key.id] or ""
    spec[key.id] = inputStr(value, key.name)
  end
end

return inputs
