
local CONSUME = {}

CONSUME.input_specs = {
  { output = 'consumed', typename = 'consume_list' },
}

function CONSUME.activatedAbility(actor, inputvalues)
  return nil
end

function CONSUME.validate(actor, inputvalues)
  return inputvalues.consumed
end

function CONSUME.perform(actor, inputvalues)
  for _,idx in ipairs(inputvalues.consumed) do
    local index = idx + actor:getBufferSize()+1
    local card = actor:getBackBufferCard(index)
    actor:removeBufferCard(index)
    actor:consumeCard(card)
  end
end

return CONSUME

