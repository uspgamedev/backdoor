
local SCHEMATICS  = require 'domain.definitions.schematics'
local TILE        = require 'common.tile'
local DB          = require 'database'

local PARAM = {}

PARAM.schema = {
  { id = 'max-range', name = "Maximum range", type = 'value', match = 'integer',
    range = {1} },
  {
    id = 'body-only', name = "Only position with body", type = 'section',
    schema = {
      { id = 'body-type', name = "Body Type", type = 'enum',
        options = 'domains.body' }
    }
  },
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
  if parameter['body-only'] then
    local body = sector:getBodyAt(i, j)
    if not body then
      return false
    end
    local typename = parameter['body-only']['body-type']
    if typename then
      local actual_typename = body:getSpecName()
      local ok = false
      repeat
        local parent = DB.loadSpec('body', actual_typename)['extends']
        if actual_typename == typename then
          ok = true
          break
        end
        actual_typename = parent
      until not parent
      if not ok then return false end
    end
  end
  if parameter['empty-tile'] and sector:getBodyAt(i, j) then
    return false
  end
  local tile = sector:getTile(i, j)
  if parameter['non-wall'] and tile and tile.type == SCHEMATICS.WALL then
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
