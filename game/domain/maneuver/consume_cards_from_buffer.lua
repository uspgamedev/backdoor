
local ACTIONDEFS  = require 'domain.definitions.action'
local CONSUME     = {}

CONSUME.param_specs = {
  { output = 'consumed', typename = 'consume_list' },
}

function CONSUME.activatedAbility(actor, sector, params)
  return nil
end

function CONSUME.validate(actor, sector, params)
  return params.consumed
end

function CONSUME.perform(actor, sector, params)
  for _,idx in ipairs(params.consumed) do
    local index = idx + actor:getBufferSize()+1
    local card = actor:getBackBufferCard(index)
    actor:removeBufferCard(index)
    actor:consumeCard(card)
  end
end

return CONSUME

