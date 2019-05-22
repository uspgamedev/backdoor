
local SCHEMATICS = require 'domain.definitions.schematics'

local INFO = [[
DO NOT USE THIS TOGETHER WITH OTHER TRANSFORMERS
(except for the bootstrap TRANSFORMER)
]]

local PALETTE = { SCHEMATICS.NAUGHT, SCHEMATICS.FLOOR, SCHEMATICS.WALL,
                  SCHEMATICS.EXIT, SCHEMATICS.ALTAR }

local TRANSFORMER = {}

TRANSFORMER.schema = {
  { id = 'layout-info', type = 'description',
    info = INFO },
  { id = 'map', name = 'Map', type = 'tilemap',
    minwidth = 5, minheight = 5, maxwidth = 50, maxheight = 50,
    palette = PALETTE
  },
  { id = 'offset', name = "Offset", type = 'vector', size = 2, range = {0,50},
    signature = { 'x', 'y' } }
}

function TRANSFORMER.process(sectorinfo, params)
  local map = params['map']
  local ox, oy = unpack(params['offset'])
  local mw, mh = sectorinfo.grid.getMargins()

  for y = 0, map.height - 1 do
    for x = 0, map.width - 1 do
      local real_x, real_y = 1 + mw + ox + x, 1 + mh + oy + y
      local raw = map.data[1 + y * map.width + x]
      local fill = PALETTE[raw]
      sectorinfo.grid.set(real_x, real_y, fill)
    end
  end

  local drops = {}
  for j, i, _ in sectorinfo.grid.iterate() do
      drops[i] = drops[i] or {}
      drops[i][j] = {}
  end

  sectorinfo.drops = drops

  sectorinfo.encounters = {}

  print("Applied fixed layout")
  return sectorinfo
end

return TRANSFORMER

