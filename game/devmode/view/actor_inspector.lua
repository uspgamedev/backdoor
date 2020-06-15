
local ACTIONDEFS = require 'domain.definitions.action'
local IMGUI = require 'imgui'

return function (actor)

  return "Actor Inspector", 2, function(gui)
    local hp = actor:getBody():getHP()
    if gui.sector_view then
      gui.sector_view:lookAt(actor)
    end
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
    IMGUI.Text(("SKL: %.2f"):format(actor:getBody():getSKL()))
    IMGUI.Text(("SPD: %.2f"):format(actor:getBody():getSPD()))
    IMGUI.Text(("VIT: %.2f"):format(actor:getBody():getVIT()))
    IMGUI.Separator()
    IMGUI.Text(("EFC: %d"):format(actor:getBody():getEFC()))
    IMGUI.Text(("FIN: %d"):format(actor:getBody():getFIN()))
    IMGUI.Text(("RES: %d"):format(actor:getBody():getRES()))
    IMGUI.Separator()
    local focus_per_cycle = actor:getBody():getFocusRegen()
                          * ACTIONDEFS.CYCLE_UNIT
    IMGUI.Text(("Focus Regen: %.2f focus/cycle"):format(focus_per_cycle))
    local turns_per_cycle = actor:getBody():getSpeed() / ACTIONDEFS.MAX_ENERGY
                                                       * ACTIONDEFS.CYCLE_UNIT
    IMGUI.Text(("Speed: %.2f turns/cycle"):format(turns_per_cycle))
  end

end
