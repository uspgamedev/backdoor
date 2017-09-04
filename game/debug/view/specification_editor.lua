
local IMGUI = require 'imgui'
local DB    = require 'database'
local INPUT = require 'debug.view.input'

return function(spec, domain_name, title, delete, parent)

  local inputs = {}
  for _,key in DB.schemaFor(domain_name) do
    table.insert(inputs, INPUT(key.type, spec, key, parent))
  end

  return title .. " Editor", 2, function(self)
    for _,input in ipairs(inputs) do
      input(self)
    end
    IMGUI.Spacing()
    IMGUI.Indent(360)
    if IMGUI.Button("Delete") then
      delete()
      return true
    end
    IMGUI.Unindent(360)
  end

end

