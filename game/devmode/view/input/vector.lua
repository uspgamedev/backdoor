
-- luacheck: no self

local IMGUI = require 'imgui'
local class = require 'lux.class'

local setfenv = setfenv
local ipairs = ipairs
local setmetatable = setmetatable
local math = math

local VectorEditor = class:new()

local _signature_mt = {
  __index = function(_, k)
    return tonumber(k)
  end
}

function VectorEditor:instance(obj, _elementspec, _fieldschema)

  setfenv(1, obj)

  local _vector = _elementspec[_fieldschema.id] or {}
  _elementspec[_fieldschema.id] = _vector
  local _size = _fieldschema.size
  local _range = _fieldschema.range
  local _default = _fieldschema.default or 0
  local _signature = setmetatable(_fieldschema.signature or
                                  {'x','y','z','w'},
                                  _signature_mt)
  local _component_inputs = {}
  for i = 1, _size do
    _vector[i] = _vector[i] or _default
    local input = {
      id = i,
      name = _signature[i],
    }
    _component_inputs[i] = input
  end

  local function check_range(new)
    if _range then
      new = math.max(_range[1],
                     _range[2] and math.min(_range[2], new) or new)
    end
    return new
  end

  function input(gui) -- luacheck: no unused, no global
    IMGUI.Text(("%s"):format(_fieldschema.name))
    IMGUI.Columns(2, _fieldschema.id, false)
    for i, component_input in ipairs(_component_inputs) do
      IMGUI.PushID(("%s#%d"):format(_fieldschema.name, component_input.id))
      IMGUI.Text(("%s"):format(component_input.name))
      IMGUI.SameLine()
      local new, changed = IMGUI.InputInt("", _vector[i])
      IMGUI.PopID()
      if changed then _vector[i] = check_range(new) end
      if i % 2 == 0 then IMGUI.NextColumn() end
      if i % 4 == 0 then IMGUI.Spacing() end
    end
    IMGUI.Columns(1)
    IMGUI.Spacing()
    IMGUI.Spacing()
  end

  function __operator:call(gui) -- luacheck: no global
    return obj.input(gui)
  end
end

return { vector = VectorEditor }

