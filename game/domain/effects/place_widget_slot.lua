
local FX = {}

FX.schema = {
  { id = 'actor', name = "Target Actor", type = 'value', match = "actor" },
  { id = 'card', name = "Card Specname", type = 'value', match = "card" },
  { id = 'widget_slot', name = "Widget Slot", type = 'value',
    match = "widget_slot" },
}

function FX.process(actor, sector, params)
  actor:placeWidget(params.widget_slot, params.card)
end

return FX
