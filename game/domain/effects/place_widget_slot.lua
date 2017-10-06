
local FX = {}

FX.schema = {
  { id = 'actor', name = "Target Actor", type = 'value', match = "actor" },
  { id = 'cardspec', name = "Card Specname", type = 'value', match = "cardspec" },
  { id = 'widget_slot', name = "Widget Slot", type = 'value', match = "widget_slot" },
}

function FX.process(actor, sector, params)
  actor:setSlot(params.widget_slot, params.cardspec)
end

return FX
