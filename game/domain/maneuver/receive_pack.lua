
local RECEIVEPACK = {}

RECEIVEPACK.input_specs = {
  { output = 'consumed', name = 'consume_list' },
  { output = 'pack', name = 'pack_list'}
}

function RECEIVEPACK.activatedAbility(actor, inputvalues)
  return nil
end

function RECEIVEPACK.exhaustionCost(actor, inputvalues)
  return 0
end

function RECEIVEPACK.validate(actor, inputvalues)
  return inputvalues.consumed and inputvalues.pack
end

function RECEIVEPACK.perform(actor, inputvalues)
  for _,card in ipairs(inputvalues.consumed) do
    actor:consumeCard(card)
  end
  for _,card in ipairs(inputvalues.pack) do
    card:setOwner(actor)
    actor:addCardToBackbuffer(card)
  end
end

return RECEIVEPACK

