
local IMGUI = require 'imgui'

return function (body)

  return "Body Inspector", 2, function(gui)
    local hp = body:getHP()
    if gui.sector_view then
      gui.sector_view:lookAt(body)
    end
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
    IMGUI.Text(("SKL: %d"):format(body:getSKL()))
    IMGUI.Text(("SPD: %d"):format(body:getSPD()))
    IMGUI.Text(("VIT: %d"):format(body:getVIT()))
    IMGUI.Separator()
    IMGUI.Text(("EFC: %d"):format(body:getEFC()))
    IMGUI.Text(("FIN: %d"):format(body:getFIN()))
    IMGUI.Text(("RES: %d"):format(body:getRES()))
    IMGUI.Separator()
    IMGUI.Text(("Base HP: %.2f"):format(body:getBaseMaxHP()))
    IMGUI.Text(("Extra HP: %+d%%"):format(body:getExtraMaxHP() * 100))
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
  end

end
