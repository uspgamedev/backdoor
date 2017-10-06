
local DB = require 'database'

local PARAM = {}

PARAM.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'cardspec'

function PARAM.isValid(sector, actor, parameter, value)
  return value and not not DB.loadSpec('card', value)
end

return PARAM

