
local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'amount', name = "Amount", type = 'value', match = 'integer',
    range = {0,100} },
  { id = 'projectile', name = "Is projectile?", type = 'boolean' },
  { id = 'sfx', name = "SFX", type = 'enum',
    options = 'resources.sfx',
    optional = true },
  { id = 'output', name = "Label", type = 'output' }
}

function FX.preview (_, fieldvalues)
  local amount = fieldvalues['amount']
  local target = fieldvalues['target']
  return ("deal %s damage to %s"):format(amount, target)
end

function FX.process (actor, fieldvalues)
  local amount = fieldvalues['amount']
  local target = fieldvalues['target']
  local result = target:takeDamageFrom(amount, actor)

  if fieldvalues['projectile'] then
    coroutine.yield('report', {
      type = 'projectile',
      actor = actor,
      target = { target:getPos() },
    })
  end

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
