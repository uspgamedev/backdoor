
local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'value', name = "value", type = 'value', match = 'integer',
    range = {0,100} },
  { id = 'projectile', name = "Is projectile?", type = 'boolean' },
  { id = 'sfx', name = "SFX", type = 'enum',
    options = 'resources.sfx',
    optional = true },
  { id = 'output', name = "Label", type = 'output' }
}

function FX.preview (_, fieldvalues)
  local value = fieldvalues['value']
  local target = fieldvalues['target']
  return ("deal %s damage to %s"):format(value, target)
end

function FX.process (actor, fieldvalues)
  local value = fieldvalues['value']
  local target = fieldvalues['target']

  if fieldvalues['projectile'] then
    coroutine.yield('report', {
      type = 'projectile',
      actor = actor,
      target = { target:getPos() },
    })
  end

  local result = target:takeDamageFrom(value, actor)

  coroutine.yield('report', {
    type = 'take_damage',
    source = actor,
    body = target,
    amount = result.dmg,
    sfx = fieldvalues.sfx,
  })

  return result
end

return FX
