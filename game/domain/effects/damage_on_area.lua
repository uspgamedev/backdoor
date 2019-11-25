
local TILE    = require 'common.tile'
local ATTR    = require 'domain.definitions.attribute'
local FX = {}

FX.schema = {
  { id = 'center', name = "Target position", type = 'value', match = 'pos' },
  { id = 'size', name = "Area Size", type = 'value', match = 'integer',
    range = {1} },
  { id = 'base', name = "Base Power", type = 'integer', range = {0,100} },
  { id = 'attr', name = "Scaling Factor", type = 'value', match = 'integer' },
  { id = 'mod', name = "%Mod", type = 'integer', range = {1,10000},
    default = 100 },
  { id = 'ignore_owner', name = "Ignore Owner", type = 'boolean'},
}

function FX.preview (_, fieldvalues)
  local base, attr, mod = fieldvalues.base, fieldvalues.attr, fieldvalues.mod
  local amount = ATTR.EFFECTIVE_POWER(base, attr, mod)
  local size = fieldvalues['size'] * 2 - 1
  return ("Deal %s damage on a %s-radius area around %s")
    :format(amount, size, fieldvalues['center'])
end

function FX.process (actor, fieldvalues)
  local sector  = actor:getBody():getSector()
  local ci, cj  = unpack(fieldvalues['center'])
  local size    = fieldvalues['size']
  local base    = fieldvalues['base']
  local attr    = fieldvalues['attr']
  local mod     = fieldvalues['mod']
  local ignore_owner = fieldvalues['ignore_owner']
  local amount = ATTR.EFFECTIVE_POWER(base, attr, mod)
  for i=ci-size+1,ci+size-1 do
    for j=cj-size+1,cj+size-1 do
      local body = sector:getBodyAt(i, j) if body then
        if (not ignore_owner or body ~= actor:getBody()) and
            TILE.dist(i,j,ci,cj) <= size - 1 then
          local result = body:takeDamageFrom(amount, actor)
          coroutine.yield('report', {
            type = 'text_rise',
            body = body,
            text_type = 'damage',
            amount = result.dmg,
          })
        end
      end
    end
  end
end

return FX
