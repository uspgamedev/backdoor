
local maneuver = {}

maneuver.schema = {
  { id = 'consumed', type = 'consume_list' },
}

function maneuver.validate(actor, sector, params)
  return params.consumed
end

function maneuver.perform(actor, sector, params)
  for _,idx in ipairs(params.consumed) do
    local index = idx + actor:getBufferSize()+1
    print("consuming: "..index)
    local card = actor:getBackBufferCard(index)
    actor:removeBufferCard(index)
    actor:consumeCard(card)
  end
end

return maneuver

