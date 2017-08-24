
return function (actor)

  return "Actor Inspector", function(self)
    local hp = actor:getBody():getHP()
    self.sector_view:lookAt(actor)
    imgui.Text(("ID: %s"):format(actor:getId()))
    imgui.PushItemWidth(100)
    local changed, newhp = imgui.SliderInt("Hit Points", hp, 1,
                                           actor:getBody():getMaxHP())
    imgui.PopItemWidth()
    if changed then
      actor:getBody():setHP(newhp)
    end
  end

end
