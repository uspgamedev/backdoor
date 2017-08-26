
-- dependencies
local RANDOM       = require 'common.random'
local TRANSFORMERS = require 'lux.pack' 'domain.transformers'
local SectorGrid      = require 'domain.transformers.helpers.sectorgrid'

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

-- generation of sector, pretty straightforward
local function generate()
  local w = _params.general.width
  local h = _params.general.height
  local mw = _params.general.mw
  local mh = _params.general.mh
  local sector = SectorGrid(w, h, mw, mh)
  TRANSFORMERS.rooms(sector, _params.rooms)
  TRANSFORMERS.maze(sector, _params.maze)
  TRANSFORMERS.connections(sector, _params.connections)
  TRANSFORMERS.deadends(sector, _params.deadends)
  print(sector)
  return sector
end

-- generation of sector with controlled seeds
return function(s)
  local seed = s or RANDOM.generateSeed()
  RANDOM.setSeed(seed)
  print("SEED:", seed)
  return generate()
end

