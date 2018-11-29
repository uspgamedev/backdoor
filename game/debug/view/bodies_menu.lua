
local IMGUI = require 'imgui'
local Util  = require "steaming.util"

return function()

  local selected = nil

  return "Current Route", 1, function(gui)
    for body in pairs(Util.findSubtype 'body') do
      local identity = ("%s: %s"):format(body:getId(), body:getSpec('name'))
      if IMGUI.Selectable(identity, body == selected) then
        selected = body
        gui:push("body_inspector", body)
      end
    end
  end

end
