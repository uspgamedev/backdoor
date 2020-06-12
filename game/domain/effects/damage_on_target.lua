
local ATTR    = require 'domain.definitions.attribute'
local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'base', name = "Base Power", type = 'integer', range = {0,100} },
  { id = 'attr', name = "Scaling Factor", type = 'value', match = 'integer' },
  { id = 'mod', name = "%Mod", type = 'integer', default = 100,
    range = {1,10000} },
  { id = 'projectile', name = "Is projectile?", type = 'boolean' },
  { id = 'sfx', name = "SFX", type = 'enum',
    options = 'resources.sfx',
    optional = true },
}

function FX.preview (actor, fieldvalues)
  local base, attr, mod = fieldvalues.base, fieldvalues.attr, fieldvalues.mod
  local attr_value = actor.getAttribute and actor:getAttribute(attr) or 3
  local amount = ATTR.EFFECTIVE_POWER(base, attr_value, mod)
  return ("Deal %d (%d + %2d%% %s) damage to %s")
          :format(amount, base, mod, attr, fieldvalues.target)
end

function FX.process (actor, fieldvalues)
  local base, attr, mod = fieldvalues.base, fieldvalues.attr, fieldvalues.mod
  local amount = ATTR.EFFECTIVE_POWER(base, attr, mod)
  local result = fieldvalues.target:takeDamageFrom(amount, actor)

  if fieldvalues['projectile'] then
    coroutine.yield('report', {
      type = 'projectile',
      actor = actor,
      target = { fieldvalues['target']:getPos() },
    })
  end

  coroutine.yield('report', {
    type = 'take_damage',
    source = actor,
    body = fieldvalues['target'],
    amount = result.dmg,
    sfx = fieldvalues.sfx,
  })
end

return FX
