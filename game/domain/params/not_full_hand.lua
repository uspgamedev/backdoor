
local PARAM = {}

PARAM.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'boolean'

function PARAM.isValid(actor, parameter, value)
  return not actor:isHandFull()
end

return PARAM

