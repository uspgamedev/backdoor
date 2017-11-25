
local IMGUI = require 'imgui'

return function()

  local selected = nil

  return "Current Route", 1, function(self)
    for body in pairs(Util.findSubtype 'body') do
      if IMGUI.Selectable(body:getId(), body == selected) then
        selected = body
        self:push("body_inspector", body)
      end
    end
  end

end

