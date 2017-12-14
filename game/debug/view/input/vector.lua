
local IMGUI = require 'imgui'
local INPUT = require 'debug.view.input'
local DB    = require 'database'

local inputs = {}
local signature_mt = {
  __index = function(self, k)
    return tonumber(k)
  end
}

function inputs.vector(spec, key)

  local vector = spec[key.id] or {}
  spec[key.id] = vector
  local selected = nil
  local size = key.size
  local range = key.range
  local default = key.default or 0
  local signature = setmetatable(key.signature or
                                 {'x','y','z','w'},
                                 signature_mt)
  local subschemas = {}
  for i=1, size do
    vector[i] = vector[i] or default
    local subkey = {
      id = i,
      name = signature[i],
    }
    subschemas[i] = subkey
  end

  local function check_range(new)
    if range then
      new = math.max(range[1],
                     range[2] and math.min(range[2], new) or new)
    end
    return new
  end

  return function(self)
    IMGUI.Text(("%s"):format(key.name))
    IMGUI.Columns(2, key.id, false)
    for i, subkey in ipairs(subschemas) do
      IMGUI.PushID(("%s#%d"):format(key.name, subkey.id))
      IMGUI.Text(("%s"):format(subkey.name))
      IMGUI.SameLine()
      local changed, new = IMGUI.InputInt("", vector[i])
      IMGUI.PopID()
      if changed then vector[i] = check_range(new) end
      if i % 2 == 0 then IMGUI.NextColumn() end
      if i % 4 == 0 then IMGUI.Spacing() end
    end
    IMGUI.Columns(1)
    IMGUI.Spacing()
    IMGUI.Spacing()
  end
end

return inputs

