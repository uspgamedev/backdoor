
local IMGUI = require 'imgui'
local INPUT = {}
package.loaded['devmode.view.input'] = INPUT

for _,file in ipairs(love.filesystem.getDirectoryItems "devmode/view/input") do
  if file:match "^.+%.lua$" then
    file = file:gsub("%.lua", "")
    if file ~= 'init' then
      for k,input in pairs(require('devmode.view.input.' .. file)) do
        INPUT[k] = input
      end
    end
  end
end

local function _invalid(spec, field)
  return function (gui)
    IMGUI.PushStyleColor("Text", 0.8, 0.6, 0, 1)
    IMGUI.Text(("Unknown field type: %s"):format(field.type))
    IMGUI.PopStyleColor(1)
  end
end

local meta = {}

function meta:__call(input_typename, ...)
  return (INPUT[input_typename] or _invalid)(...) or _invalid()
end

return setmetatable(INPUT, meta)

