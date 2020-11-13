
local IMGUI = require 'imgui'
local INPUT = require 'devmode.view.input'
local class = require 'lux.class'

local setfenv = setfenv
local table = table
local ipairs = ipairs

local ArrayEditor = class:new()

-- luacheck: no self
function ArrayEditor:instance(obj, _elementspec, _fieldschema)

  setfenv(1, obj)

  local _array = _elementspec[_fieldschema.id] or {}

  _elementspec[_fieldschema.id] = _array

  local _inputs = {}
  for i,itemspec in ipairs(_array) do
    _inputs[i] = {}
    for j,subfield_schema in ipairs(_fieldschema.schema) do
      _inputs[i][j] = INPUT(itemspec, subfield_schema)
    end
  end

  function obj.input(gui)
    local removed
    IMGUI.PushID(_fieldschema.id)
    for i,_ in ipairs(_array) do
      IMGUI.Text(("%s #%d"):format(_fieldschema.name, i))
      IMGUI.Indent(20)
      for j,_ in ipairs(_fieldschema.schema) do
        IMGUI.PushID(i)
        _inputs[i][j](gui)
        IMGUI.PopID()
      end
      if IMGUI.Button("Delete##array-button-"..i) then
        removed = i
      end
      IMGUI.Unindent(20)
    end
    IMGUI.PopID()
    if removed then
      table.remove(_array, removed)
      table.remove(_inputs, removed)
    end
    if IMGUI.Button("New " .. _fieldschema.name) then
      local spec = {}
      table.insert(_array, spec)
      local field_inputs = {}
      for j,subfield_schema in ipairs(_fieldschema.schema) do
        field_inputs[j] = INPUT(spec, subfield_schema)
      end
      table.insert(_inputs, field_inputs)
    end
  end

  function obj.__operator:call(gui)
    return obj.input(gui)
  end

end

return { array = ArrayEditor }

