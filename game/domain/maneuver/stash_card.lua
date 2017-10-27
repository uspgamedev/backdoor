
local maneuver = {}

maneuver.schema = {
  { id = 'card_index', type = 'card_index' }
}

function maneuver.validate(actor, sector, params)
  return params.card_index
end

function maneuver.perform(actor, sector, params)
  actor:addCardToBackBuffer(actor:removeHandCard(params.card_index))
  --FIXME: BUFF ACTOR!
end

return maneuver

