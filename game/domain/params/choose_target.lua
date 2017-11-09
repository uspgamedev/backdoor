
local TILE = require 'common.tile'

local PARAM = {}

PARAM.schema = {
  { id = 'max-range', name = "Maximum range", type = 'value', match = 'integer',
    range = {1} },
  { id = 'body-only', name = "Only position with body", type = 'boolean' },
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'pos'

function PARAM.isWithinRange(sector, actor, parameter, value)
  local max = parameter['max-range'] if max then
    local i,j = actor:getPos()
    local dist = TILE.dist(i,j,unpack(value))
    if dist > max then
      return false
    end
  end
  return true
end

function PARAM.isValid(sector, actor, parameter, value)
  if not sector:isInside(unpack(value)) then
    return false
  end
  if parameter['body-only'] and not sector:getBodyAt(unpack(value)) then
    return false
  end
  if not PARAM.isWithinRange(sector, actor, parameter, value) then
    return false
  end
  local i, j = unpack(value)
  if not actor.fov[i][j] or actor.fov[i][j] == 0 then
    return false
  end
  return true
end

return PARAM
