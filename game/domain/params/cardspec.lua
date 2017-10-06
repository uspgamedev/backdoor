
local PARAM = {}

PARAM.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'cardspec'

function PARAM.isValid(sector, actor, parameter, params)
  return true
end

return PARAM

