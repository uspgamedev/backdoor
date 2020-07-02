
local ACTIONDEFS = require 'domain.definitions.action'
local IMGUI = require 'imgui'

return function (body)

  return "Body Inspector", 2, function(gui)
    local hp = body:getHP()
    IMGUI.Text(("ID: %s"):format(body:getId()))
    IMGUI.Text(("Species: %s"):format(body:getSpec('name')))
    IMGUI.Separator()
    IMGUI.PushItemWidth(100)
    local newhp, changed = IMGUI.SliderInt("Hit Points", hp, 1,
                                           body:getMaxHP())
    IMGUI.PopItemWidth()
    if changed then
      body:setHP(newhp)
    end
    IMGUI.Separator()
    IMGUI.Text(("Base HP: %.2f"):format(body:getBaseHP()))
    IMGUI.Separator()
    IMGUI.Text("Widgets:")
    IMGUI.Indent(20)
    for _,widget in body:eachWidget() do
      local txt = ("%s [%d]"):format(
        widget:getName(), widget:getWidgetCharges() - widget:getUsages()
      )
      IMGUI.Text(txt)
    end
    IMGUI.Unindent(20)
    local actor = body:getActor()
    if actor then
      if gui.sector_view then
        gui.sector_view:lookAt(actor)
      end
      IMGUI.Text(("ID: %s"):format(actor:getId()))
      IMGUI.Text(("Title: %s"):format(actor:getTitle()))
      IMGUI.Separator()
      IMGUI.Text(("PWRLVL: %.2f"):format(actor:getPowerLevel()))
      IMGUI.Separator()
      IMGUI.Text(("COR: %d"):format(actor:getCOR()))
      IMGUI.Text(("ARC: %d"):format(actor:getARC()))
      IMGUI.Text(("ANI: %d"):format(actor:getANI()))
      IMGUI.Separator()
      IMGUI.Text(("SKL: %.2f"):format(actor:getSKL()))
      IMGUI.Text(("SPD: %.2f"):format(actor:getSPD()))
      IMGUI.Text(("VIT: %.2f"):format(actor:getVIT()))
      IMGUI.Separator()
      local focus_per_cycle = actor:getFocusRegen()
                            * ACTIONDEFS.CYCLE_UNIT
      IMGUI.Text(("Focus Regen: %.2f focus/cycle"):format(focus_per_cycle))
      local turns_per_cycle = actor:getSpeed() / ACTIONDEFS.MAX_ENERGY
                                                         * ACTIONDEFS.CYCLE_UNIT
      IMGUI.Text(("Speed: %.2f turns/cycle"):format(turns_per_cycle))
      IMGUI.Text(("Extra HP: %+d"):format((actor:getExtraHP() - 1) * 100).."%%")
    end
  end

end
