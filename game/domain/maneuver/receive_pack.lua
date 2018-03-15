
local RECEIVEPACK = {}

RECEIVEPACK.input_specs = {
  { output = 'consumed', typename = 'consume_list' },
  { output = 'pack', typename = 'pack_list'}
}

function RECEIVEPACK.activatedAbility(actor, inputvalues)
  return nil
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

