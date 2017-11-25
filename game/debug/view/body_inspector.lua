
local IMGUI = require 'imgui'

return function (body)

  return "Body Inspector", 2, function(self)
    local hp = body:getHP()
    self.sector_view:lookAt(body)
    IMGUI.Text(("ID: %s"):format(body:getId()))
    IMGUI.PushItemWidth(100)
    local changed, newhp = IMGUI.SliderInt("Hit Points", hp, 1,
                                           body:getMaxHP())
    IMGUI.PopItemWidth()
    if changed then
      body:setHP(newhp)
    end
    IMGUI.Separator()
    IMGUI.Text(("VIT: %d"):format(body:getVIT()))
    IMGUI.Text(("DEF: %d"):format(body:getDEF()))
    IMGUI.Text(("DEFDIE: d%d"):format(body:getBaseDEF()))
  end

end
