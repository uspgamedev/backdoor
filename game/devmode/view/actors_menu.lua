
local IMGUI = require 'imgui'
local Util  = require "steaming.util"

return function()

  local selected = nil

  return "Current Route", 1, function(gui)
    local actors = Util.findSubtype 'actor'
    if actors then
      for actor,_ in pairs(actors) do
        local identity = ("%s: %s"):format(actor:getId(), actor:getTitle())
        if IMGUI.Selectable(identity, actor == selected) then
          selected = actor
          gui:push("actor_inspector", actor)
        end
      end
    else
      IMGUI.Text("No actors found")
    end
  end

end
