
local JSON = require 'dkjson'
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

local fs = love.filesystem

return function()
  local filedata = assert(fs.newFileData("database/domains/card/spark_rod.json"))
  local input = JSON.decode(filedata:getString())
  local keyorder = KEYORDER.getOrderedKeys(input)
  for i, key in ipairs(keyorder) do
    print(i, key)
  end
  print(JSON.encode(input, { indent = true, keyorder = keyorder }))
end

