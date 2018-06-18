
local APT = require 'domain.definitions.aptitude'

local function hp(vit, con)
  return APT.HP(vit, con-3)
end

return function()
  for vit=1,12,0.5 do
    print(vit, hp(vit, 1), hp(vit, 2), hp(vit, 3), hp(vit, 4), hp(vit, 5))
  end
end

