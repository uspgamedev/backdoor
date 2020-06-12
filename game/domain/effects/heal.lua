
local ATTR    = require 'domain.definitions.attribute'

local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'base', name = "Base Power", type = 'integer', range = {0,100} },
  { id = 'attr', name = "Scaling Factor", type = 'value', match = 'integer' },
  { id = 'mod', name = "% Mod", type = 'value', match = 'integer',
    range = {1} },
}

function FX.preview(actor, fieldvalues)
  local base, attr, mod = fieldvalues.base, fieldvalues.attr, fieldvalues.mod
  local attr_value = actor.getAttribute and actor:getAttribute(attr) or 3
  local amount = ATTR.EFFECTIVE_POWER(base, attr_value, mod)
  return ("heal %d (%d + %2d%% %s) hit points for %s")
         :format(amount, base, mod, attr, fieldvalues['target'])
end

function FX.process(_, fieldvalues)
  local base, attr, mod = fieldvalues.base, fieldvalues.attr, fieldvalues.mod
  local target = fieldvalues['target']
  local amount = ATTR.EFFECTIVE_POWER(base, attr, mod)
  local effective_amount = target:heal(amount)
  coroutine.yield('report', {
    type = 'heal',
    body = target,
    amount = effective_amount,
  })
end

return FX
