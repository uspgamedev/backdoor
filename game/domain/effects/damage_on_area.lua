
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
  { id = 'projectile', name = "Is projectile?", type = 'boolean' },
  { id = 'sfx', name = "SFX", type = 'enum',
    options = 'resources.sfx',
    optional = true },
}

function FX.preview (actor, fieldvalues)
  local base, attr, mod = fieldvalues.base, fieldvalues.attr, fieldvalues.mod
  local attr_value = actor.getAttribute and actor:getAttribute(attr) or 3
  local amount = ATTR.EFFECTIVE_POWER(base, attr_value, mod)
  local size = fieldvalues['size'] - 1
  if size > 0 then
    return ("Deal %d (%d + %2d%% %s) damage on a %s-radius area around %s")
           :format(amount, base, mod, attr, size, fieldvalues['center'])
  else
    return ("Deal %d (%d + %2d%% %s) damage at %s")
           :format(amount, base, mod, attr, fieldvalues['center'])
  end
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
  if fieldvalues['projectile'] then
    coroutine.yield('report', {
      type = 'projectile',
      actor = actor,
      target = { ci, cj },
    })
  end
  for i=ci-size+1,ci+size-1 do
    for j=cj-size+1,cj+size-1 do
      local body = sector:getBodyAt(i, j) if body then
        if (not ignore_owner or body ~= actor:getBody()) and
            TILE.dist(i,j,ci,cj) <= size - 1 then
          local result = body:takeDamageFrom(amount, actor)
          coroutine.yield('report', {
            type = 'take_damage',
            source = actor,
            body = body,
            amount = result.dmg,
            sfx = fieldvalues['sfx'],
          })
        end
      end
    end
  end
end

return FX
