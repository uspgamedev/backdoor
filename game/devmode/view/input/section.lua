
local IMGUI = require 'imgui'
local INPUT = require 'devmode.view.input'
local class = require 'lux.class'

local setfenv = setfenv
local ipairs = ipairs
local type = type
local require = require

local SectionEditor = class:new()

-- luacheck: no self
function SectionEditor:instance(obj, _elementspec, _fieldschema, _parent)

  setfenv(1, obj)

  local _subschema = _fieldschema.schema
  local _backup = {}
  local _subfield_inputs = {}

  if type(_subschema) == "string" then
    _subschema = require ('domain.'.._subschema).schema
  end

  for i, subfield_schema in ipairs(_subschema) do
    local input_lambda
    _subfield_inputs[i] = {
      id = ("%s:%s"):format(_fieldschema.id, subfield_schema.id),
      input = function(section_spec)
        input_lambda = input_lambda or INPUT(section_spec, subfield_schema,
                                             _parent)
        return input_lambda
      end
    }
  end

  function obj.input(gui)
    local element = _elementspec[_fieldschema.id]
    local enabled
    enabled = IMGUI.Checkbox(_fieldschema.name, not not element)
    if not element and (enabled or _fieldschema.required) then
      element = _backup
    elseif element and not enabled and not _fieldschema.required then
      _backup = element
      element = false
    end
    if element then
      IMGUI.Indent(20)
      for i, _ in ipairs(_subschema) do
        IMGUI.PushID(_subfield_inputs[i].id)
        _subfield_inputs[i].input(element)(gui)
        IMGUI.PopID()
      end
      IMGUI.Unindent(20)
    end
    _elementspec[_fieldschema.id] = element
  end

  function obj.__operator:call(gui)
    return obj.input(gui)
  end
end

return { section = SectionEditor }

