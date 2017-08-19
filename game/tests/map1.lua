
-- dependencies
local RANDOM       = require 'common.random'
local TRANSFORMERS = require 'lux.pack' 'domain.transformers'
local MapGrid      = require 'domain.transformers.helpers.mapgrid'

-- seed value
local _seed = RANDOM.generateSeed()
RANDOM.setSeed(_seed)


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

-- generation of map, pretty straightforward
local function generate()
  local w = _params.general.width
  local h = _params.general.height
  local mw = _params.general.mw
  local mh = _params.general.mh
  local map = MapGrid(w, h, mw, mh)
  TRANSFORMERS.rooms(map, _params.rooms)
  TRANSFORMERS.maze(map, _params.maze)
  TRANSFORMERS.connections(map, _params.connections)
  TRANSFORMERS.deadends(map, _params.deadends)
  print(map)
  return map
end

-- generation of map with controlled seeds
local function test(s)
  local seed = s or RANDOM.generateSeed()
  RANDOM.setSeed(seed)
  print("SEED:", seed)
  return generate()
end

-- returns as a table mapping to the functions above
return {
  generate = generate,
  test = test
}
