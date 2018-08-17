
local FX = {}

FX.schema = {
  { id = 'card_list', name = "Consumed card list", type = 'value',
    match = 'consume_list' },
}

function FX.preview(actor, fieldvalues)
  return ("Consume up to %s cards"):format(fieldvalues['card_list'])
end

function FX.process (actor, fieldvalues)
  local consume_list = fieldvalues['card_list']
  local bufsize = actor:getBufferSize()
  local n = #consume_list
  for i=n,1,-1 do
    local card = actor:removeBufferCard(consume_list[i])
    actor:consumeCard(card)
  end
end

return FX

