
local INPUT = {}

INPUT.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'integer'

function INPUT.isValid(_, _, _)
  return true
end

return INPUT

