
local FX = {}

FX.schema = {
  { id = 'amount', name = "Focus Amount", type = 'value',
    match = 'integer', range = {1,3} },
}

function FX.preview(_, fieldvalues)
  return ("gain %s Focus"):format(fieldvalues['amount'])
end

function FX.process (actor, fieldvalues)
  local amount = fieldvalues['amount']
  actor:gainFocus(amount)

  coroutine.yield('report', {
    type = 'text_rise',
    text_type = 'focus',
    body = actor:getBody(),
    amount = amount,
  })
  return amount
end

return FX

