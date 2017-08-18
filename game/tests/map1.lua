
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
    mw = 3,
    mh = 3,
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
    n = 128,
  },
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

local function test(s)
  local seed = s or math.random(1000000, 9999999)
  math.randomseed(seed)
  print("SEED:", seed)
  return generate()
end

return {
  generate = generate,
  test = test
}

