
-- dependencies
local Transformers = require 'lux.pack' 'domain.transformers'
local Grid = require 'domain.transformers.helpers.grid'

-- seed value
local seed = tonumber(tostring(os.time()):sub(-7):reverse())

-- test values
local params = {
  general = {
    width = 48,
    height = 48,
    mw = 2,
    mh = 2,
  },
  rooms = {
    minw = 3,
    minh = 3,
    maxw = 9,
    maxh = 9,
    count = 8,
    tries = 128,
  },
  maze = {
    double = false
  },
  deadends = {
    n = 64
  }
}

local map = Grid(
  params.general.width,
  params.general.height,
  params.general.mw,
  params.general.mh
)

math.randomseed(seed)
Transformers.rooms(map, params.rooms)
Transformers.maze(map, params.maze)
Transformers.deadends(map, params.deadends)

print(map)

return map

