
--- Get an attribute value of user

local RANDOM = require 'common.random'
local OP = {}

OP.schema = {
  { id = 'rolls', name = "Rolls", type = 'value', match = 'integer', range = {1} },
  { id = 'sides', name = "Sides", type = 'value', match = 'integer', range = {1} },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'integer'

function OP.process(actor, params)
  return RANDOM.rollDice(params.rolls, params.sides)
end

return OP

