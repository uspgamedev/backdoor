
local FX = {}

FX.schema = {
  { id = 'value', name = "Modify Exp By", type = 'value', match = 'integer' },
}

function FX.process(actor, fieldvalues)
  actor:modifyExpBy(fieldvalues.value)
end

return FX

