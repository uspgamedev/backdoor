
local IMGUI = require 'imgui'
local Util  = require "steaming.util"

return function()

  local selected = nil

  return "Current Route", 1, function(gui)
    local bodies = Util.findSubtype 'body'
    if bodies then
      for body in pairs() do
        local identity = ("%s: %s"):format(body:getId(), body:getSpec('name'))
        if IMGUI.Selectable(identity, body == selected) then
          selected = body
          gui:push("body_inspector", body)
        end
      end
    else
      IMGUI.Text("No bodies found")
    end
  end

end
