
local PARAM = {}

PARAM.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'upgrade-list'

function PARAM.isValid(sector, actor, parameter, value)
  return true
end

return PARAM

