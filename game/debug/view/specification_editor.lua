
local DB = require 'database'

local spec_item = {}

for _,file in ipairs(love.filesystem.getDirectoryItems "debug/view/input") do
  if file:match "^.+%.lua$" then
    file = file:gsub("%.lua", "")
    for k,input in pairs(require('debug.view.input.' .. file)) do
      spec_item[k] = input
    end
  end
end

--[[ Invalid input ]]-----------------------------------------------------------

local function _invalid(spec, key)
  return function (self)
    imgui.PushStyleColor("Text", 200, 100, 0, 255)
    imgui.Text(("Unknown input type: %s"):format(key.type))
    imgui.PopStyleColor(1)
  end
end

--[[ Menu rendering ]]----------------------------------------------------------

return function(spec, domain_name, title, delete)

  local inputs = {}
  for _,key in DB.schemaFor(domain_name) do
    local input = spec_item[key.type]
    table.insert(inputs, (input or _invalid)(spec, key) or _invalid())
  end

  return title .. " Editor", 1, function(self)
    imgui.PushItemWidth(120)
    for _,input in ipairs(inputs) do
      input(self)
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

