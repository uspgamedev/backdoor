
local RANDOM  = require 'common.random'
local ATTR    = require 'domain.definitions.attribute'

local FX = {}

FX.schema = {
  { id = 'target', name = "Target", type = 'value', match = 'body' },
  { id = 'base', name = "Heal power base", type = 'integer',
    range = {1} },
  { id = 'attr', name = "Heal power mod", type = 'value', match = 'integer',
    range = {1} },
}

function FX.preview(actor, fieldvalues)
  local attr, base = fieldvalues.attr, fieldvalues.base
  local amount = ATTR.EFFECTIVE_POWER(base, attr)
  return ("Heal %s hit points"):format(amount)
end

function FX.process(actor, fieldvalues)
  local attr, base = fieldvalues.attr, fieldvalues.base
  local target = fieldvalues['target'] 
  local amount = ATTR.EFFECTIVE_POWER(base, attr)
  local effective_amount = target:heal(amount)
  coroutine.yield('report', {
    type = 'text_rise',
    text_type = 'heal',
    body = target,
    amount = effective_amount,
  })
end

return FX

