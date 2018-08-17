
local IMGUI = require 'imgui'

return function (value, name, range)
  return IMGUI.InputText(name, value, 64)
end
