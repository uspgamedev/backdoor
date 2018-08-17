
local IMGUI = require 'imgui'

return function()

  local selected = nil

  return "Current Route", 1, function(gui)
    for actor,_ in pairs(Util.findSubtype 'actor') do
      local identity = ("%s: %s"):format(actor:getId(), actor:getTitle())
      if IMGUI.Selectable(identity, actor == selected) then
        selected = actor
        gui:push("actor_inspector", actor)
      end
    end
  end

end

