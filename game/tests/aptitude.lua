
local ANSICOLOR = require 'lux.term.ansicolors'
local APT = require 'domain.definitions.aptitude'

return function()

  print[[
| lv | -2  | -1  |  0  | +1  | +2  |
|----|-----|-----|-----|-----|-----|]]

  local acc = {}
  for lv=1,20 do
    local line = ("| %2d |"):format(lv)
    local line2 = "|    |"
    for apt=-2,2 do
      local xp = APT.REQUIRED_ATTR_UPGRADE(apt, lv)
      local i = apt+5
      line = line .. ("%s%+5d%s|"):format(ANSICOLOR.green, xp, ANSICOLOR.white)
      xp = (acc[i] or 0) + xp
      line2 = line2 .. ("%5d|"):format(xp)
      acc[i] = xp
    end
    print(line)
    print(line2)
  end

end

