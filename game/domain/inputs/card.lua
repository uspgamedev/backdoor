
local DB = require 'database'

local INPUT = {}

INPUT.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'card'

function INPUT.isValid(actor, fieldvalues, value)
  return true
end

return INPUT

