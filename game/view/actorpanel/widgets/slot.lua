
local Node = require 'view.node'

local Slot = Class({ __includes = { Node } })

function Slot:init(widget)
  Node.init(self)
  self:setWidget(widget)
end

function Slot:setWidget(widget)
  self.widget = widget or false
end

function Slot:render(g)
  local widget = self.widget
  if widget then
    local icon = RES.loadTexture(widget:getIconTexture() or 'icon-none')
    local iw, ih = icon:getDimensions()
    icon:setFilter('linear', 'linear')
    g.setColor(COLORS[widget:getRelatedAttr()])
    g.rectangle("fill", 0, 0, _SQRSIZE, _SQRSIZE)
    g.setColor(COLORS.BLACK)
    g.draw(icon, 0, 0, 0, _SQRSIZE/iw, _SQRSIZE/ih)
  elseif wtype == 1 then
    g.setColor(COLORS.BLACK)
    g.printf(PLACEMENTS[PLACEMENTS[i]]:lower(), 0, 0, _SQRSIZE, "center")
  end
end

return Slot

