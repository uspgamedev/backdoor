
local IMGUI = require 'imgui'
local INPUT = require 'debug.view.input'
local DB    = require 'database'

local _inputs = {}

function _inputs.section(spec, field, parent)

  local schema = field.schema
  local backup = {}
  local inside_schema = {}

  if type(schema) == "string" then
    schema = require ('domain.'..schema).schema
  end

  for i, subfield in ipairs(schema) do
    local input_lambda
    inside_schema[i] = {
      id = ("%s:%s"):format(field.id, subfield.id),
      input = function(section_spec)
        input_lambda = input_lambda or INPUT(subfield.type, section_spec,
                                             subfield, parent)
        return input_lambda
      end
    }
  end

  return function(self)
    local element = spec[field.id]
    local enabled
    enabled = select(2, IMGUI.Checkbox(field.name, not not element))
    if not element and (enabled or field.required) then
      element = backup
    elseif element and not enabled and not field.required then
      backup = element
      element = false
    end
    if element then
      IMGUI.Indent(20)
      for i, subfield in ipairs(schema) do
        IMGUI.PushID(inside_schema[i].id)
        inside_schema[i].input(element)(self)
        IMGUI.PopID()
      end
      IMGUI.Unindent(20)
    end
    spec[field.id] = element
  end
end

return _inputs

