
local DIR = require 'domain.definitions.dir'

local PARAM = {}

PARAM.schema = {
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'dir'

function PARAM.isValid(actor, parameter, value)
  --for _,dir = ipairs() do end
  --local sector = actor:getBody():getSector()
  --local i, j = unpack(value)
  --if not sector:isInside(i, j) then
  --  return false
  --end
  --if parameter['body-only'] and not sector:getBodyAt(i, j) then
  --  return false
  --end
  --if parameter['empty-tile'] and sector:getBodyAt(i, j) then
  --  return false
  --end
  --local tile = sector:getTile(i, j)
  --if parameter['non-wall'] and tile and tile.type == SCHEMATICS.WALL then
  --  return false
  --end
  --if not PARAM.isWithinRange(actor, parameter, value) then
  --  return false
  --end
  --if not actor.fov[i][j] or actor.fov[i][j] == 0 then
  --  return false
  --end
  return true
end

return PARAM
