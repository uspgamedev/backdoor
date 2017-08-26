
local DB = require 'database'

local inputs = {}

function inputs.list(spec, key)

  local list = spec[key.id] or {}
  local selected = nil
  local typeoptions = {}

  for _,option in DB.subschemaTypes(key.id) do
    table.insert(typeoptions, option)
  end

  local function delete()
    table.remove(list, selected)
  end

  return function(self)
    imgui.Text(("%ss:"):format(key.name))
    imgui.Indent(20)
    for i,element in ipairs(list) do
      local view = ("%2d: %s"):format(i, element.typename)
      if imgui.Selectable(view, selected == i) then
        selected = i
        self:push('specification_editor', element,
                  key.id .. '/' .. element.typename, key.name, delete)
      end
    end
    if imgui.Button("New " .. key.name) then
      self:push(
        'list_picker', key.name, typeoptions,
        function (value)
          if value then
            table.insert(list, { typename = typeoptions[value] })
            return true
          end
          return 0
        end
      )
    end
    imgui.Unindent(20)
  end
end

return inputs

