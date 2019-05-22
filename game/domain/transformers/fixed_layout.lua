
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
  { id = 'offset', name = "Tilemap offset", type = 'vector', size = 2,
    range = { 0, 50 } },
  { id = 'player-pos', name = "Player position", type = 'vector', size = 2,
    range = { 0, 50 } },
}

function TRANSFORMER.process(sectorinfo, params)
  local map = params['map']
  local ox, oy = unpack(params['offset'])
  local player_x, player_y = unpack(params['player-pos'])
  local mw, mh = sectorinfo.grid.getMargins()

  local last_exit_id = nil

  for y = 0, map.height - 1 do
    for x = 0, map.width - 1 do
      local real_x, real_y = 1 + mw + ox + x, 1 + mh + oy + y
      local raw = map.data[1 + y * map.width + x]
      local fill = PALETTE[raw]
      sectorinfo.grid.set(real_x, real_y, fill)
      if fill == SCHEMATICS.EXIT then
        local exit
        last_exit_id, exit = next(sectorinfo.exits, last_exit_id)
        if last_exit_id then
          exit.pos = { real_y, real_x }
        end
      end
    end
  end

  local drops = {}
  for j, i, _ in sectorinfo.grid.iterate() do
      drops[i] = drops[i] or {}
      drops[i][j] = {}
  end

  sectorinfo.drops = drops
  sectorinfo.encounters = {}
  sectorinfo.player_pos = { mw + ox + player_x, mh + oy + player_y }

  return sectorinfo
end

return TRANSFORMER

