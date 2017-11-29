
local CONSUME = {}

CONSUME.param_specs = {
  { output = 'consumed', typename = 'consume_list' },
}

function CONSUME.activatedAbility(actor, params)
  return nil
end

function CONSUME.validate(actor, params)
  return params.consumed
end

function CONSUME.perform(actor, params)
  for _,idx in ipairs(params.consumed) do
    local index = idx + actor:getBufferSize()+1
    local card = actor:getBackBufferCard(index)
    actor:removeBufferCard(index)
    actor:consumeCard(card)
  end
end

return CONSUME

