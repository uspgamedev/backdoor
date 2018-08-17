
--- Get an attribute value of user

local RANDOM = require 'common.random'
local OP = {}

OP.schema = {
  { id = 'rolls', name = "Rolls", type = 'value', match = 'integer', range = {1} },
  { id = 'sides', name = "Sides", type = 'value', match = 'integer', range = {1} },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'integer'

function OP.preview(actor, fieldvalues)
  return ("%sd%s"):format(fieldvalues['rolls'], fieldvalues['sides'])
end

function OP.process(actor, fieldvalues)
  return RANDOM.rollDice(fieldvalues.rolls, fieldvalues.sides)
end

return OP

