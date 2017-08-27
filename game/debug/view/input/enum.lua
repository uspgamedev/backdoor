
local IMGUI = require 'imgui'
local DB = require 'database'

local inputs = {}

function inputs.enum(spec, key)

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

  return function(self)
    local changed,value = IMGUI.Combo(key.name, current, options, #options, 10)
    if changed then
      current = value
      spec[key.id] = options[value]
    end
  end
end

return inputs

