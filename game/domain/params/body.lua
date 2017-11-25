
local DB = require 'database'

local PARAM = {}

PARAM.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'body'

function PARAM.isValid(sector, actor, parameter, value)
  return true
end

return PARAM

