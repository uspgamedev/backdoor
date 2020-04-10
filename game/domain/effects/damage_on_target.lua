
local ATTR    = require 'domain.definitions.attribute'
local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'base', name = "Base Power", type = 'integer', range = {0,100} },
  { id = 'attr', name = "Scaling Factor", type = 'value', match = 'integer' },
  { id = 'mod', name = "%Mod", type = 'integer', default = 100,
    range = {1,10000} },
  { id = 'sfx', name = "SFX", type = 'enum',
    options = 'resources.sfx',
    optional = true },
}

function FX.preview (_, fieldvalues)
  local base, attr, mod = fieldvalues.base, fieldvalues.attr, fieldvalues.mod
  local amount = ATTR.EFFECTIVE_POWER(base, attr, mod)
  return ("Deal %s damage to %s"):format(amount, fieldvalues.target)
end

function FX.process (actor, fieldvalues)
  local base, attr, mod = fieldvalues.base, fieldvalues.attr, fieldvalues.mod
  local amount = ATTR.EFFECTIVE_POWER(base, attr, mod)
  local result = fieldvalues.target:takeDamageFrom(amount, actor)

  coroutine.yield('report', {
    type = 'text_rise',
    text_type = 'damage',
    body = fieldvalues['target'],
    amount = result.dmg,
    sfx = fieldvalues.sfx,
  })
end

return FX
