
local INPUT = {}

INPUT.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'boolean'

function INPUT.isValid(actor, fieldvalues, value)
  return actor:isHandEmpty()
end

return INPUT

