
local SCHEMATICS = require 'domain.definitions.schematics'

local INFO = [[
DO NOT USE THIS TOGETHER WITH OTHER TRANSFORMERS
(except for the bootstrap TRANSFORMER)
]]

local TRANSFORMER = {}

TRANSFORMER.schema = {
  { id = 'layout-info', type = 'description',
    info = INFO },
  { id = 'map', name = 'Map', type = 'tilemap',
    minwidth = 5, minheight = 5, maxwidth = 50, maxheight = 50,
    palette = { SCHEMATICS.NAUGHT, SCHEMATICS.FLOOR, SCHEMATICS.WALL,
                SCHEMATICS.EXIT, SCHEMATICS.ALTAR }
  },
  { id = 'x-offset', name = "X-Offset", type = 'integer', range = {5,50} },
  { id = 'y-offset', name = "Y-Offset", type = 'integer', range = {5,50} },
}

function TRANSFORMER.process(sectorinfo, params)
  local map = params['map']
  local ox, oy = params['x-offset'], params['y-offset']
  for i = 1, map.height do
    for j = 1, map.width do

    end
  end
  return sectorinfo
end

return TRANSFORMER

