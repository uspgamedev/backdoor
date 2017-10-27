
local maneuver = {}

maneuver.schema = {
  { id = 'consumed', type = 'consume_list' },
  { id = 'pack', type = 'pack_list'}
}

function maneuver.validate(actor, sector, params)
  return params.consumed and params.pack
end

function maneuver.perform(actor, sector, params)
  for _,idx in ipairs(params.consumed) do
    local card = table.remove(params.pack, idx)
    actor:consumeCard(card)
  end
  for _,cardspec in ipairs(params.pack) do
    actor:addCardToBackbuffer(cardspec)
  end
end

return maneuver

