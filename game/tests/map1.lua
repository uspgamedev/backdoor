
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

local _map = MapGrid(
  _params.general.width,
  _params.general.height,
  _params.general.mw,
  _params.general.mh
)

math.randomseed(_seed)
TRANSFORMERS.rooms(_map, _params.rooms)
TRANSFORMERS.maze(_map, _params.maze)
TRANSFORMERS.connections(_map, _params.connections)
TRANSFORMERS.deadends(_map, _params.deadends)

print(_map)

return _map

