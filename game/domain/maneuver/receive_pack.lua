
local maneuver = {}

maneuver.schema = {
  { id = 'consumed', type = 'consume_list' },
  { id = 'pack', type = 'pack_list'}
}

function maneuver.validate(actor, sector, params)
  return params.consumed and params.pack
end

function maneuver.perform(actor, sector, params)
  for _,card in ipairs(params.consumed) do
    actor:consumeCard(card)
  end
  for _,card in ipairs(params.pack) do
    actor:addCardToBackbuffer(card)
  end
end

return maneuver

