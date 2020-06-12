
local FX = {}

FX.schema = {
  { id = 'amount', name = "Amount of cards", type = 'value', match = 'integer',
    range = {1} }, 
}

function FX.preview(actor, fieldvalues)
  return ("draw %s cards"):format(fieldvalues['amount'])
end

function FX.process (actor, fieldvalues)
  for i = 1, fieldvalues.amount do
    actor:drawCard()
  end 
end

return FX
