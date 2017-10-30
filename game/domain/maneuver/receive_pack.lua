
local RECEIVEPACK = {}

RECEIVEPACK.param_specs = {
  { output = 'consumed', typename = 'consume_list' },
  { output = 'pack', typename = 'pack_list'}
}

function RECEIVEPACK.activatedAbility(actor, sector, params)
  return nil
end

function RECEIVEPACK.validate(actor, sector, params)
  return params.consumed and params.pack
end

function RECEIVEPACK.perform(actor, sector, params)
  for _,card in ipairs(params.consumed) do
    actor:consumeCard(card)
  end
  for _,card in ipairs(params.pack) do
    card:setOwner(actor)
    actor:addCardToBackbuffer(card)
  end
end

return RECEIVEPACK

