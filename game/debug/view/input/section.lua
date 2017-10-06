
local IMGUI = require 'imgui'
local INPUT = require 'debug.view.input'
local DB    = require 'database'

local _inputs = {}

function _inputs.section(spec, key)

  local schema = key.schema
  local backup = {}
  local inside_schema = {}

  if type(schema) == "string" then
    schema = require ('domain.'..schema).schema
  end

  for i, subkey in ipairs(schema) do
    local input_lambda
    inside_schema[i] = {
      id = ("%s:%s"):format(key.id, subkey.id),
      input = function(section_spec)
        input_lambda = input_lambda or INPUT(subkey.type, section_spec, subkey)
        return input_lambda
      end
    }
  end

  return function(self)
    local element = spec[key.id]
    local enabled
    enabled = select(2, IMGUI.Checkbox(key.name, not not element))
    if not element and (enabled or key.required) then
      element = backup
    elseif element and not enabled and not key.required then
      backup = element
      element = false
    end
    if element then
      IMGUI.Indent(20)
      for i, subkey in ipairs(schema) do
        IMGUI.PushID(inside_schema[i].id)
        inside_schema[i].input(element)(self)
        IMGUI.PopID()
      end
      IMGUI.Unindent(20)
    end
    spec[key.id] = element
  end
end

return _inputs

