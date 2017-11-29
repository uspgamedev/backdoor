
local PARAM = {}

PARAM.schema = {
  { id = 'source', name = "Card source", type = 'enum',
    options = { 'HAND', 'PACK' } },
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'integer'

function PARAM.isValid(actor, parameter, value)
  return true
end

return PARAM

