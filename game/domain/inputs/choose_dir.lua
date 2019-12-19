
local DIR = require 'domain.definitions.dir'

local INPUT = {}

INPUT.schema = {
  { id = 'reach', name = "Reach", type = 'value', match = 'integer',
    range = {1,99} },
  { id = 'body-block', name = "Stop on bodies", type = 'boolean' },
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'dir'

function INPUT.isValid(actor, fieldvalues, value)
  for _,dir in ipairs(DIR) do
    dir = DIR[dir]
    if dir[1] == value[1] and dir[2] == value[2] then
      return true
    end
  end
  return false
end

return INPUT
