
local DB = require 'database'

local inputs = {}

function inputs.enum(spec, key)
  return function(self)
    -- Build option list from given array or from a database domain
    local options = key.options
    if type(options) == 'string' then
      local domain = DB.loadDomain(options)
      options = {}
      for k,v in pairs(domain) do
        table.insert(options,k)
      end
      table.sort(options)
    end
    -- Find the index of the currently assigned option
    local current = 0
    for i,option in ipairs(options) do
      if option == spec[key.id] then
        current = i
        break
      end
    end
    -- Value getter/setter
    local function value(newvalue)
      if newvalue then
        current = newvalue
        spec[key.id] = options[newvalue]
      else
        return current
      end
    end
    imgui.InputText(key.name, spec[key.id] or "<none>", 64, { "ReadOnly" })
    if imgui.IsItemClicked() then
      self:push("list_picker", key.name, options, value)
    end
  end
end

return inputs

