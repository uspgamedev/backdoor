
return function()

  local selected = nil

  return "Current Route", 1, function(self)
    for actor,_ in pairs(Util.findSubtype 'actor') do
      if imgui.Selectable(actor:getId(), actor == selected) then
        selected = actor
        self:push("actor_inspector", actor)
      end
    end
  end

end

