
local TILE = require 'common.tile'

local PARAM = {}

PARAM.schema = {
  { id = 'max-range', name = "Maximum range", type = 'value', match = 'integer',
    range = {1} },
  { id = 'body-only', name = "Only position with body", type = 'boolean' },
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'pos'

function PARAM.isValid(sector, actor, parameter, value)
  if not sector:isInside(unpack(value)) then
    return false
  end
  if parameter['body-only'] and not sector:getBodyAt(unpack(value)) then
    return false
  end
  local max = parameter['max-range'] if max then
    local i,j = actor:getPos()
    local dist = TILE.dist(i,j,unpack(value))
    if dist > max then
      return false
    end
  end
  return true
end

return PARAM

