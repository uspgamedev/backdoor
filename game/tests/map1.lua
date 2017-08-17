
-- dependencies
local TRANSFORMERS = require 'lux.pack' 'domain.transformers'
local Grid = require 'domain.transformers.helpers.grid'

-- seed value
local _seed = tonumber(tostring(os.time()):sub(-7):reverse())

-- test values
local _params = {
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
    count = 12,
    tries = 128,
  },
  maze = {
    double = false
  },
  deadends = {
    n = 64
  }
}

local _map = Grid(
  _params.general.width,
  _params.general.height,
  _params.general.mw,
  _params.general.mh
)

math.randomseed(_seed)
TRANSFORMERS.rooms(_map, _params.rooms)
TRANSFORMERS.maze(_map, _params.maze)
TRANSFORMERS.deadends(_map, _params.deadends)

print(_map)

return _map

