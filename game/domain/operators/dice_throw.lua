
--- Get an attribute value of user

local RANDOM = require 'common.random'
local OP = {}

OP.schema = {
  { id = 'rolls', name = "Rolls", type = 'value', match = 'integer', range = {1} },
  { id = 'sides', name = "Sides", type = 'value', match = 'integer', range = {1} },
  { id = 'output', name = "Label", type = 'output' }
}

OP.type = 'integer'

function OP.process(actor, sector, params)
  local N, D = params.rolls, params.sides
  local sum = 0
  for i = 1, N do
    sum = sum + D == 1 and 1 or RANDOM.generate(D)
  end
  return sum
end

return OP

