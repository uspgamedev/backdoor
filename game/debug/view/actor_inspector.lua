
local IMGUI = require 'imgui'

return function (actor)

  return "Actor Inspector", 2, function(self)
    local hp = actor:getBody():getHP()
    self.sector_view:lookAt(actor)
    IMGUI.Text(("ID: %s"):format(actor:getId()))
    IMGUI.Text(("Title: %s"):format(actor:getTitle()))
    IMGUI.Separator()
    IMGUI.PushItemWidth(100)
    local changed, newhp = IMGUI.SliderInt("Hit Points", hp, 1,
                                           actor:getBody():getMaxHP())
    IMGUI.PopItemWidth()
    if changed then
      actor:getBody():setHP(newhp)
    end
    IMGUI.Text(("PWRLVL: %d"):format(actor:getPowerLevel()))
    IMGUI.Separator()
    IMGUI.Text(("COR: %d"):format(actor:getCOR()))
    IMGUI.Text(("ARC: %d"):format(actor:getARC()))
    IMGUI.Text(("ANI: %d"):format(actor:getANI()))
    IMGUI.Text(("SPD: %d"):format(actor:getSPD()))
    IMGUI.Separator()
    IMGUI.Text(("VIT: %d"):format(actor:getBody():getVIT()))
    IMGUI.Text(("DEF: %d"):format(actor:getBody():getDEF()))
    IMGUI.Text(("DEFDIE: d%d"):format(actor:getBody():getBaseDEF()))
  end

end
