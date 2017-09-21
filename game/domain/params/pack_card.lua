
local PARAM = {}

PARAM.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'card'

function PARAM.isValid(sector, actor, value)
  return true
end

return PARAM

