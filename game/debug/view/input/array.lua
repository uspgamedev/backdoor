
local IMGUI = require 'imgui'
local INPUT = require 'debug.view.input'
local DB    = require 'database'

local inputs = {}

function inputs.array(spec, key)

  local array = spec[key.id] or {}
  local selected = nil

  spec[key.id] = array

  return function(self)
    local removed
    for i,element in ipairs(array) do
      IMGUI.Text(("%s #%d"):format(key.name, i))
      IMGUI.Indent(20)
      for j,subkey in ipairs(key.schema) do
        IMGUI.PushID(i)
        INPUT(subkey.type, element, subkey)(self)
        IMGUI.PopID()
      end
      if IMGUI.Button("Delete##"..i) then
        removed = i
      end
      IMGUI.Unindent(20)
    end
    if removed then
      table.remove(array,removed)
    end
    if IMGUI.Button("New " .. key.name) then
      table.insert(array, {})
    end
  end
end

return inputs

