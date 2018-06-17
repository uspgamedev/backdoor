
local IMGUI = require 'imgui'

return function (actor)

  local player = actor:getBody():getSector():getRoute().getControlledActor()
  return "Actor Inspector", 2, function(gui)
    local hp = actor:getBody():getHP()
    gui.sector_view:lookAt(actor)
    IMGUI.Text(("ID: %s"):format(actor:getId()))
    IMGUI.Text(("Title: %s"):format(actor:getTitle()))
    IMGUI.Separator()
    IMGUI.PushItemWidth(100)
    local newhp, changed = IMGUI.SliderInt("Hit Points", hp, 1,
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
    IMGUI.Separator()
    IMGUI.Text(("SPD: %d"):format(actor:getSPD()))
    IMGUI.Separator()
    IMGUI.Text(("DEF: %.2f"):format(actor:getBody():getDEF()))
    IMGUI.Text(("EFC: %.2f"):format(actor:getBody():getEFC()))
    IMGUI.Text(("VIT: %.2f"):format(actor:getBody():getVIT()))
    IMGUI.Separator()
    IMGUI.Text(("RES: %d"):format(actor:getBody():getRES()))
    IMGUI.Text(("FIN: %d"):format(actor:getBody():getFIN()))
    IMGUI.Text(("CON: %d"):format(actor:getBody():getCON()))
    IMGUI.Separator()
    IMGUI.Text(("Max DR: %d"):format(actor:getBody():getMAXDR()))
    IMGUI.Text(("Consumption: %d"):format(actor:getBody():getConsumption()))
  end

end
