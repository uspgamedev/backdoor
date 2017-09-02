
local IMGUI = require 'imgui'

return function (value, name, range)

  local _, newvalue = IMGUI.InputText(name, value, 64)

  return newvalue

end
