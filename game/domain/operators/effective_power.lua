
--- Calculate the effective power of an effect given a base value, the
--  associated attribute, and the modifying factor.

local DEFS = require 'domain.definitions'
local ATTR = require 'domain.definitions.attribute'
local Formula = require 'common.formula'

local OP = {}

OP.schema = {
  { id = 'base', name = "Base Power", type = 'integer', range = {0,100} },
  { id = 'attr', name = "Attribute", type = 'enum',
    options = DEFS.ALL_ATTRIBUTES },
  { id = 'mod', name = "% Mod", type = 'value', match = 'integer',
    range = {1,1000} },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'integer'

function OP.process(actor, fieldvalues)
  local base, attr, mod = fieldvalues.base, fieldvalues.attr, fieldvalues.mod
  local attr_value = actor:getAttribute(attr)
  return ATTR.EFFECTIVE_POWER(base, attr_value, mod)
end

function OP.preview(actor, fieldvalues)
  local base, attr, mod = fieldvalues.base, fieldvalues.attr, fieldvalues.mod
  local amount
  if actor.id then -- is it a valid actor?
    amount = OP.process(actor, fieldvalues)
  end
  return Formula(amount, ("%d + %2d%% %s"):format(base, mod, attr))
end

return OP

