
local CONSUME = {}

CONSUME.input_specs = {
  { output = 'consumed', name = 'consume_list' },
}

function CONSUME.card(actor, inputvalues)
  return nil
end

function CONSUME.activatedAbility(actor, inputvalues)
  return nil
end

function CONSUME.exhaustionCost(actor, inputvalues)
  return 0
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

