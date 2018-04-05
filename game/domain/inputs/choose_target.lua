
local SCHEMATICS  = require 'domain.definitions.schematics'
local TILE        = require 'common.tile'
local DB          = require 'database'

local INPUT = {}

INPUT.schema = {
  { id = 'max-range', name = "Maximum range", type = 'value', match = 'integer',
    range = {0} },
  {
    id = 'body-only', name = "Only position with body", type = 'section',
    schema = {
      { id = 'body-type', name = "Body Type", type = 'enum',
        options = 'domains.body' }
    }
  },
  { id = 'empty-tile', name = "Only empty position", type = 'boolean' },
  { id = 'dif-fact', name = "Only different faction", type = 'boolean' },
  { id = 'non-wall', name = "Only without wall", type = 'boolean' },
  { id = 'aoe-hint', name = "Size of previewed AoE", type = 'integer',
    range = {1} },
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'pos'

function INPUT.isWithinRange(actor, fieldvalues, value)
  local max = fieldvalues['max-range'] if max then
    local i,j = actor:getPos()
    local dist = TILE.dist(i,j,unpack(value))
    if dist > max then
      return false
    end
  end
  return true
end

function INPUT.isValid(actor, fieldvalues, value)
  local sector = actor:getBody():getSector()
  local i, j = unpack(value)
  if not sector:isInside(i, j) then
    return false
  end
  if fieldvalues['body-only'] then
    local body = sector:getBodyAt(i, j)
    if not body then
      return false
    end
    local typename = fieldvalues['body-only']['body-type']
    if typename and not body:isSpec(typename) then
      return false
    end
  end
  if fieldvalues['empty-tile'] and sector:getBodyAt(i, j) then
    return false
  end
  if fieldvalues['dif-fact'] and sector:getBodyAt(i, j):getFaction() == actor:getBody():getFaction() then
    return false
  end
  local tile = sector:getTile(i, j)
  if fieldvalues['non-wall'] and tile and tile.type == SCHEMATICS.WALL then
    return false
  end
  if not INPUT.isWithinRange(actor, fieldvalues, value) then
    return false
  end
  local fov = actor:getFov(sector)
  if not fov[i][j] or fov[i][j] == 0 then
    return false
  end
  return true
end

return INPUT

