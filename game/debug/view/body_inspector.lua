
local IMGUI = require 'imgui'

return function (body)

  return "Body Inspector", 2, function(gui)
    local hp = body:getHP()
    gui.sector_view:lookAt(body)
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
    IMGUI.Text(("VIT: %d"):format(body:getVIT()))
    IMGUI.Text(("DEF: %d"):format(body:getDEF()))
    IMGUI.Text(("DEFDIE: d%d"):format(body:getBaseDEF()))
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
