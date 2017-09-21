
local PARAM = {}

PARAM.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'none'

function PARAM.isValid(sector, actor, parameter, value)
  return actor:isHandEmpty()
end

return PARAM

