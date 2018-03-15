
local INPUT = {}

INPUT.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'upgrade-list'

function INPUT.isValid(actor, fieldvalues, value)
  return true
end

return INPUT

