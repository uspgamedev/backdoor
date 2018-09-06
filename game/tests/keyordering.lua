
local KEYORDER = require 'common.keyorder'

local input = {
  hi = true,
  id = "id#1101",
  things = {
    common = 0,
    notcommon = 1,
    afield = {
      {
        goodmorning = 1024,
        goodevening = "hhhhh",
      },
      {
        goodmorning = 2048,
        goodevening = "aaaaaa",
      },
      {
        {
          nested = true,
          arraytable = true,
        },
        {
          nested = 1,
          arraytable = 1,
        },
      }
    }
  }
}

return function()
  for i, key in ipairs(KEYORDER.getOrderedKeys(input)) do
    print(i, key)
  end
end

