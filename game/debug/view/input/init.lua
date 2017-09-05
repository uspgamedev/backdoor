
local IMGUI = require 'imgui'
local INPUT = {}
package.loaded['debug.view.input'] = INPUT

for _,file in ipairs(love.filesystem.getDirectoryItems "debug/view/input") do
  if file:match "^.+%.lua$" then
    file = file:gsub("%.lua", "")
    if file ~= 'init' then
      for k,input in pairs(require('debug.view.input.' .. file)) do
        INPUT[k] = input
      end
    end
  end
end

local function _invalid(spec, key)
  return function (self)
    IMGUI.PushStyleColor("Text", 200, 100, 0, 255)
    IMGUI.Text(("Unknown input type: %s"):format(key.type))
    IMGUI.PopStyleColor(1)
  end
end

local meta = {}

function meta:__call(input_typename, ...)
  return (INPUT[input_typename] or _invalid)(...) or _invalid()
end

return setmetatable(INPUT, meta)

