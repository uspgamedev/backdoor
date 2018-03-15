
local INPUT = {}

INPUT.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'sector'

function INPUT.isValid(actor, fieldvalues, value)
  return true
end

return INPUT

