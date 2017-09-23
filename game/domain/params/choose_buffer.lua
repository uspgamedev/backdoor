
local PARAM = {}

PARAM.schema = {
  { id = 'empty', name = "Only empty buffers", type = 'boolean' },
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'integer'

function PARAM.isValid(sector, actor, parameter, value)
  if parameter['empty'] then
    return not actor:isBufferEmpty(value)
  else
    return true
  end
end

return PARAM

