
local maneuver = {}

maneuver.schema = {
  { id = 'slot', type = 'widget_slot' },
  { id = 'card_index', type = 'card_index' }
}

function maneuver.validate(actor, sector, params)
  return actor:getHandCard(params.card_index)
end

function maneuver.perform(actor, sector, params)
  local card = actor:getHandCard(params.card_index)
  actor:playCard(params.card_index)
  actor:setSlot(params.slot, card)
end

return maneuver

