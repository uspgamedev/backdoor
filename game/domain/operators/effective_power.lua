
--- Calculate the effective power of an effect given a base value, the
--  associated attribute, and the modifying factor.

local ATTR = require 'domain.definitions.attribute'
local Formula = require 'common.formula'

local OP = {}

OP.schema = {
  { id = 'base', name = "Base Power", type = 'integer', range = {0,100} },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'integer'

function OP.process(actor, fieldvalues)
  local card = fieldvalues.card
  local base = fieldvalues.base
  local attr, mod = card:getRelatedAttr(), card:getMod()
  local attr_value = actor:getAttribute(attr)
  return ATTR.EFFECTIVE_POWER(base, attr_value, mod)
end

function OP.preview(actor, fieldvalues)
  local card = fieldvalues.card
  local base = fieldvalues.base
  local attr, mod = card:getRelatedAttr(), card:getMod()
  if actor.id then -- is it a valid actor?
    local attr_value = actor:getAttribute(attr)
    local amount = ATTR.EFFECTIVE_POWER(base, attr_value, mod)
    local total_mod = ATTR.EFFECTIVE_MOD(attr_value, mod)
    return Formula(amount, ("%d + %d"):format(base, total_mod))
  else
    return Formula(nil, ("%d + mod"):format(base))
  end
end

return OP

