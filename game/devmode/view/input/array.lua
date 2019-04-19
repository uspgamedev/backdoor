
local IMGUI = require 'imgui'
local INPUT = require 'devmode.view.input'
local DB    = require 'database'
local class = require 'lux.class'

local setfenv = setfenv
local table = table
local ipairs = ipairs

local ArrayEditor = class:new()

function ArrayEditor:instance(obj, _elementspec, _fieldschema)

  setfenv(1, obj)

  local _array = _elementspec[_fieldschema.id] or {}
  local _selected = nil

  _elementspec[_fieldschema.id] = _array

  function input(gui)
    local removed
    for i,item in ipairs(_array) do
      IMGUI.Text(("%s #%d"):format(_fieldschema.name, i))
      IMGUI.Indent(20)
      for j,subfield_schema in ipairs(_fieldschema.schema) do
        IMGUI.PushID(i)
        INPUT(subfield_schema.type, item, subfield_schema)(gui)
        IMGUI.PopID()
      end
      if IMGUI.Button("Delete##array-button-"..i) then
        removed = i
      end
      IMGUI.Unindent(20)
    end
    if removed then
      table.remove(_array, removed)
    end
    if IMGUI.Button("New " .. _fieldschema.name) then
      table.insert(_array, {})
    end
  end

  function __operator:call(gui)
    return obj.input(gui)
  end
end

return { array = ArrayEditor }

