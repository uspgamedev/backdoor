
local RANDOM  = require 'common.random'
local ATTR    = require 'domain.definitions.attribute'
local FX = {}

FX.schema = {
  {
    id = 'attr', name = "Attribute", type = 'value',
    match = 'integer', range = {1}
  },
  { id = 'base', name = "Base Power", type = 'value',
    match = 'integer', range = {1} },
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'sfx', name = "SFX", type = 'enum',
    options = 'resources.sfx',
    optional = true },
}

function FX.process (actor, fieldvalues)
  local attr, base = fieldvalues.attr, fieldvalues.base
  local amount = RANDOM.generate(ATTR.DMG(attr, base))
  local dmg = fieldvalues.target:takeDamageFrom(amount, actor)

  coroutine.yield('report', {
    type = 'text_rise',
    text_type = 'damage',
    body = fieldvalues['target'],
    amount = dmg,
    sfx = fieldvalues.sfx,
  })
end

return FX
