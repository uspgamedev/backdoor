
local IMGUI = require 'imgui'
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
    IMGUI.PushStyleColor("Text", 200, 100, 0, 255)
    IMGUI.Text(("Unknown input type: %s"):format(key.type))
    IMGUI.PopStyleColor(1)
  end
end

--[[ Menu rendering ]]----------------------------------------------------------

return function(spec, domain_name, title, delete, parent)

  local inputs = {}
  for _,key in DB.schemaFor(domain_name) do
    local input = spec_item[key.type]
    table.insert(inputs, (input or _invalid)(spec, key, parent) or _invalid())
  end

  return title .. " Editor", 2, function(self)
    IMGUI.PushItemWidth(160)
    for _,input in ipairs(inputs) do
      input(self)
    end
    IMGUI.PopItemWidth()
    IMGUI.Spacing()
    IMGUI.Indent(360)
    if IMGUI.Button("Delete") then
      delete()
      return true
    end
    IMGUI.Unindent(360)
  end

end

