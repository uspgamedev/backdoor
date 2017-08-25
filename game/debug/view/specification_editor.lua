
local DB = require 'database'

local spec_item = {}

function spec_item:integer(spec, domain_name, key)
  local value = spec[key.id] or key.range[1]
  local changed, newvalue = imgui.InputInt(key.name, value, 1, 10)
  if changed then
    spec[key.id] = math.max(key.range[1], math.min(key.range[2], newvalue))
  end
end

function spec_item:enum(spec, domain_name, key)
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

return function(spec, domain_name, title, delete)

  return title .. " Editor", function(self)
    imgui.PushItemWidth(120)
    for _,key in DB.schemaFor(domain_name) do
      spec_item[key.type](self, spec, domain_name, key)
    end
    imgui.PopItemWidth()
    imgui.Spacing()
    imgui.Indent(180)
    if imgui.Button("Delete") then
      delete()
      return true
    end
    imgui.Unindent(180)
  end

end

