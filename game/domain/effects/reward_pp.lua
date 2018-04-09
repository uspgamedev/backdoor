
local DEFS = require 'domain.definitions'
local FX = {}

FX.schema = {
  { id = 'amount', name = "PP Amount", type = 'value',
    match = 'integer', range = {0} },
  { id = 'target', name = "Target", optional = true, type = 'value',
    match = 'body' },
}

function FX.process (actor, fieldvalues)
  local target = fieldvalues['target']
  local amount = fieldvalues['amount']
  if target then
    actor = target:getSector():getActorFromBody(target)
  end
  actor:rewardPP(amount)

  coroutine.yield('report', {
    type = 'number_rise',
    number_type = 'food',
    body = target or actor:getBody(),
    amount = amount,
  })
  return amount
end

return FX

