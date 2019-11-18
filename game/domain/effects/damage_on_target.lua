
local ATTR    = require 'domain.definitions.attribute'
local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'attr', name = "Base Power", type = 'value', match = 'integer' },
  { id = 'mod', name = "%Mod", type = 'integer', default = 100,
    range = {1,10000} },
  { id = 'sfx', name = "SFX", type = 'enum',
    options = 'resources.sfx',
    optional = true },
}

function FX.preview (_, fieldvalues)
  local attr, mod = fieldvalues.attr, fieldvalues.mod
  local amount = ATTR.EFFECTIVE_POWER(mod, attr)
  return ("Deal %s damage to target"):format(amount)
end

function FX.process (actor, fieldvalues)
  local attr, mod = fieldvalues.attr, fieldvalues.mod
  local amount = ATTR.EFFECTIVE_POWER(mod, attr)
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
