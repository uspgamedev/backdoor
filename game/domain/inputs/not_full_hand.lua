
local INPUT = {}

INPUT.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'boolean'

function INPUT.isValid(actor, fieldvalues, value)
  return not actor:isHandFull()
end

return INPUT

