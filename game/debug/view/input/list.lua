
local IMGUI = require 'imgui'
local DB = require 'database'
local IDGenerator = require 'common.idgenerator'

local _idgen = IDGenerator()

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
    IMGUI.Text(("%ss:"):format(key.name))
    IMGUI.Indent(20)
    for i,element in ipairs(list) do
      local view
      if element.output then
        view = ("%s -> [%s]"):format(element.typename, element.output)
      else
        view = ("%2d: %s"):format(i, element.typename)
      end
      if IMGUI.Selectable(view, selected == i) then
        selected = i
        self:push('specification_editor', element,
                  key.id .. '/' .. element.typename, key.name, delete, spec)
      end
    end
    if IMGUI.Button("New " .. key.name) then
      self:push(
        'list_picker', key.name, typeoptions,
        function (value)
          if value then
            local new = { typename = typeoptions[value] }
            local schema = require('domain.'..key.id..'.'..new.typename).schema
            for _,subkey in ipairs(schema) do
              if subkey.type == 'output' then
                new[subkey.id] = 'label'.._idgen.newID()
              end
            end
            table.insert(list, new)
            return true
          end
          return 0
        end
      )
    end
    IMGUI.Unindent(20)
  end
end

return inputs

