
local PARAM = {}

PARAM.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'integer'

function PARAM.isValid(actor, parameter, value)
  return actor:getExp() >= value
end

return PARAM

