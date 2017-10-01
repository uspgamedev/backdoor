
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
  local selected = nil
  local size = key.size
  local range = key.range
  local signature = setmetatable(key.signature or
                                 {'x','y','z','w'},
                                 signature_mt)
  local subschemas = {}
  for i=1, size do
    local subkey = {
      id = i,
      name = signature[i],
      type = 'integer',
      range = range,
    }
    subschemas[i] = subkey
  end

  return function(self)
    IMGUI.Text(("%s"):format(key.name))
    IMGUI.Indent(20)
    for i, subkey in ipairs(subschemas) do
      IMGUI.PushID(("%s#%d"):format(key.name, subkey.id))
      INPUT('integer', vector, subkey)(self)
      IMGUI.PopID()
    end
    IMGUI.Unindent(20)
  end
end

return inputs

