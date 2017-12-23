
local IMGUI = require 'imgui'

return function()

  local selected = nil

  return "Current Route", 1, function(self)
    for body in pairs(Util.findSubtype 'body') do
      local identity = ("%s: %s"):format(body:getId(), body:getSpec('name'))
      if IMGUI.Selectable(identity, body == selected) then
        selected = body
        self:push("body_inspector", body)
      end
    end
  end

end

