
local APT = require 'domain.definitions.aptitude'

local function food(efc, mtb)
  return APT.STAMINA(efc, mtb-3)
end

return function()
  for efc=1,12,0.5 do
    print(efc, food(efc, 1), food(efc, 2), food(efc, 3), food(efc, 4),
               food(efc, 5))
  end
end

