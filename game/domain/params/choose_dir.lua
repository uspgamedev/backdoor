
local DIR = require 'domain.definitions.dir'

local PARAM = {}

PARAM.schema = {
  { id = 'body-block', name = "Stop on bodies", type = 'boolean' },
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'dir'

function PARAM.isValid(actor, parameter, value)
  for _,dir in ipairs(DIR) do
    dir = DIR[dir]
    if dir[1] == value[1] and dir[2] == value[2] then
      return true
    end
  end
  return false
end

return PARAM
