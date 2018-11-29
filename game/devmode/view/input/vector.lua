
local IMGUI = require 'imgui'
local INPUT = require 'devmode.view.input'
local DB    = require 'database'

local inputs = {}
local signature_mt = {
  __index = function(gui, k)
    return tonumber(k)
  end
}

function inputs.vector(spec, field)

  local vector = spec[field.id] or {}
  spec[field.id] = vector
  local selected = nil
  local size = field.size
  local range = field.range
  local default = field.default or 0
  local signature = setmetatable(field.signature or
                                 {'x','y','z','w'},
                                 signature_mt)
  local subschemas = {}
  for i=1, size do
    vector[i] = vector[i] or default
    local subfield = {
      id = i,
      name = signature[i],
    }
    subschemas[i] = subfield
  end

  local function check_range(new)
    if range then
      new = math.max(range[1],
                     range[2] and math.min(range[2], new) or new)
    end
    return new
  end

  return function(gui)
    IMGUI.Text(("%s"):format(field.name))
    IMGUI.Columns(2, field.id, false)
    for i, subfield in ipairs(subschemas) do
      IMGUI.PushID(("%s#%d"):format(field.name, subfield.id))
      IMGUI.Text(("%s"):format(subfield.name))
      IMGUI.SameLine()
      local new, changed = IMGUI.InputInt("", vector[i])
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

