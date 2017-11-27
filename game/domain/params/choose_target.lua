
local SCHEMATICS  = require 'domain.definitions.schematics'
local TILE        = require 'common.tile'

local PARAM = {}

PARAM.schema = {
  { id = 'max-range', name = "Maximum range", type = 'value', match = 'integer',
    range = {1} },
  { id = 'body-only', name = "Only position with body", type = 'boolean' },
  { id = 'empty-tile', name = "Only empty position", type = 'boolean' },
  { id = 'non-wall', name = "Only without wall", type = 'boolean' },
  { id = 'aoe-hint', name = "Size of previewed AoE", type = 'integer',
    range = {1} },
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'pos'

function PARAM.isWithinRange(actor, parameter, value)
  local max = parameter['max-range'] if max then
    local i,j = actor:getPos()
    local dist = TILE.dist(i,j,unpack(value))
    if dist > max then
      return false
    end
  end
  return true
end

function PARAM.isValid(actor, parameter, value)
  local sector = actor:getBody():getSector()
  local i, j = unpack(value)
  if not sector:isInside(i, j) then
    return false
  end
  if parameter['body-only'] and not sector:getBodyAt(i, j) then
    return false
  end
  if parameter['empty-tile'] and sector:getBodyAt(i, j) then
    return false
  end
  if parameter['non-wall'] and sector:getTile(i, j).type == SCHEMATICS.WALL then
    return false
  end
  if not PARAM.isWithinRange(actor, parameter, value) then
    return false
  end
  if not actor.fov[i][j] or actor.fov[i][j] == 0 then
    return false
  end
  return true
end

return PARAM
