
local PARAM = {}

PARAM.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'integer'

function PARAM.isValid(sector, actor, parameter, value)
  return not actor:isBufferEmpty(value)
end

return PARAM

