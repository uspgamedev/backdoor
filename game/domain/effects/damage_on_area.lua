
local TILE    = require 'common.tile'
local FX = {}

FX.schema = {
  { id = 'center', name = "Target position", type = 'value', match = 'pos' },
  { id = 'size', name = "Area Size", type = 'value', match = 'integer',
    range = {1} },
  { id = 'value', name = "value", type = 'value', match = 'integer',
    range = {0,100} },
  { id = 'ignore_owner', name = "Ignore Owner", type = 'boolean'},
  { id = 'projectile', name = "Is projectile?", type = 'boolean' },
  { id = 'sfx', name = "SFX", type = 'enum',
    options = 'resources.sfx',
    optional = true },
}

function FX.preview (_, fieldvalues)
  local value = fieldvalues['value']
  local size = fieldvalues['size'] - 1
  local center = fieldvalues['center']
  if size > 0 then
    return ("deal %s damage on a %s-radius area around %s")
           :format(value, size, center)
  else
    return ("deal %s damage at %s"):format(value, center)
  end
end

function FX.process (actor, fieldvalues)
  local sector  = actor:getBody():getSector()
  local ci, cj  = unpack(fieldvalues['center'])
  local size    = fieldvalues['size']
  local ignore_owner = fieldvalues['ignore_owner']
  local value = fieldvalues['value']
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
          local result = body:takeDamageFrom(value, actor)
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
