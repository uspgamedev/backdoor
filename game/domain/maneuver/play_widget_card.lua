
local maneuver = {}

maneuver.param_specs = {
  { output = 'card_index', typename = 'card_index' },
  { output = 'widget_slot', typename = 'choose_widget_slot' },
}

function maneuver.activatedAbility(actor, sector, params)
  return nil
end

function maneuver.validate(actor, sector, params)
  return actor:getHandCard(params.card_index) and params.widget_slot
end

function maneuver.perform(actor, sector, params)
  local card = actor:getHandCard(params.card_index)
  actor:playCard(params.card_index)
  actor:setSlot(params.widget_slot, card)
end

return maneuver

