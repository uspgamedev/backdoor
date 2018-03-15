
local IMGUI = require 'imgui'

return function (value, name, range)
  local newvalue, changed = IMGUI.InputInt(name, value, 1, 10)
  if range then
    newvalue = math.max(range[1],
                        range[2] and math.min(range[2], newvalue) or newvalue)
  end
  return newvalue, changed
end

