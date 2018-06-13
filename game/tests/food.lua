
local APT = require 'domain.definitions.aptitude'

local function food(efc, mtb)
  mtb = mtb-3
  local min, max = 7 - 2.5*mtb, 25 - mtb
  local food = max - (max-min)*efc/12
  return math.floor(food)
end

return function()
  for efc=1,12,0.5 do
    print(efc, food(efc, 1), food(efc, 2), food(efc, 3), food(efc, 4),
               food(efc, 5))
  end
end

