
-- dependencies
local TRANSFORMERS = require 'lux.pack' 'domain.transformers'
local MapGrid = require 'domain.transformers.helpers.mapgrid'

-- seed value
local _seed = tonumber(tostring(os.time()):sub(-7):reverse())

-- test values
local _params = {
  general = {
    width = 32,
    height = 32,
    mw = 2,
    mh = 2,
  },
  rooms = {
    minw = 3,
    minh = 3,
    maxw = 7,
    maxh = 7,
    count = 12,
    tries = 256,
  },
  maze = {
    double = false
  },
  connections = {
    n = 128
  },
  deadends = {
    n = 128
  }
}

math.randomseed(_seed)



local function generate()
  local map = MapGrid(
    _params.general.width,
    _params.general.height,
    _params.general.mw,
    _params.general.mh
    )
  TRANSFORMERS.rooms(map, _params.rooms)
  TRANSFORMERS.maze(map, _params.maze)
  TRANSFORMERS.connections(map, _params.connections)
  TRANSFORMERS.deadends(map, _params.deadends)
  print(map)
  return map
end

for i = 1, 32 do
  print(i)
  generate()
end

return generate()

