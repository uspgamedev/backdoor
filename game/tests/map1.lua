
-- dependencies
local Transformers = require 'domain.transformers'
local Grid = require 'domain.transformers.helpers.grid'

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
  }
}

local map = Grid(
  params.general.width,
  params.general.height,
  params.general.mw,
  params.general.mh
)

Transformers.rooms(map, params.rooms)
Transformers.maze(map, params.maze)

return map

