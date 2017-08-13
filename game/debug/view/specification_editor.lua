
local DB = require 'database'

local spec_item = {}

function spec_item:integer(spec, domain_name, key)
  imgui.PushItemWidth(160)
  local value = spec[key.id]
  local _, newvalue = imgui.InputInt(key.name, value, 1, 10)
  spec[key.id] = newvalue
  imgui.PopItemWidth()
end

function spec_item:enum(spec, domain_name, key)
  local options = key.options
  if type(options) == 'string' then
    local domain = DB.loadDomain(options)
    options = {}
    for k,v in pairs(domain) do
      table.insert(options,k)
    end
  end
  local current = 0
  for i,option in ipairs(options) do
    if option == spec[key.id] then
      current = i
      break
    end
  end
  local function value(newvalue)
    if newvalue then
      current = newvalue
      spec[key.id] = options[newvalue]
    else
      return current
    end
  end
  imgui.PushItemWidth(160)
  imgui.InputText(key.name, spec[key.id] or "<none>", 64, { "ReadOnly" })
  imgui.PopItemWidth()
  if imgui.IsItemClicked() then
    self:push("list_picker", key.name, options, value)
  end
end

return function(spec, domain_name, title)

  return title .. " Editor", function(self)
    for _,key in DB.schemaFor(domain_name) do
      spec_item[key.type](self, spec, domain_name, key)
    end
  end

end

