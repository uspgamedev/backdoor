
local IMGUI = require 'imgui'
local INPUT = require 'debug.view.input'
local DB    = require 'database'

local inputs = {}

function inputs.array(spec, field)

  local array = spec[field.id] or {}
  local selected = nil

  spec[field.id] = array

  return function(self)
    local removed
    for i,element in ipairs(array) do
      IMGUI.Text(("%s #%d"):format(field.name, i))
      IMGUI.Indent(20)
      for j,subfield in ipairs(field.schema) do
        IMGUI.PushID(i)
        INPUT(subfield.type, element, subfield)(self)
        IMGUI.PopID()
      end
      if IMGUI.Button("Delete##array-button-"..i) then
        removed = i
      end
      IMGUI.Unindent(20)
    end
    if removed then
      table.remove(array,removed)
    end
    if IMGUI.Button("New " .. field.name) then
      table.insert(array, {})
    end
  end
end

return inputs

