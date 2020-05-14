
local SCHEMATICS = require 'domain.definitions.schematics'

local INFO = [[
DO NOT USE THIS TOGETHER WITH OTHER TRANSFORMERS
(except for the bootstrap TRANSFORMER)
]]

local PALETTE = { SCHEMATICS.NAUGHT, SCHEMATICS.FLOOR, SCHEMATICS.WALL,
                  SCHEMATICS.EXITUP, SCHEMATICS.EXITDOWN, SCHEMATICS.ALTAR }

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
  {
    id = 'encounters', name = "Encounters", type = 'array',
    schema = {
      { id = 'pos', name = "Position", type = 'vector', size = 2,
        range = { 0, 50, } },
      { id = 'body-specname', name = "Body Specification", type = 'enum',
        options = 'domains.body' },
      { id = 'actor-specname', name = "Actor Specification", type = 'enum',
        options = 'domains.actor', optional = true },
    }
  },
  {
    id = 'drops', name = "Drops", type = 'array',
    schema = {
      { id = 'pos', name = "Position", type = 'vector', size = 2,
        range = { 0, 50, } },
      { id = 'drop-specname', name = "Drop Specification", type = 'enum',
        options = 'domains.drop' },
    }
  },
}

local _EXIT = { [SCHEMATICS.EXITDOWN] = 'down', [SCHEMATICS.EXITUP] = 'up' }

local function _findExitByDir(exits, dir, checked)
  for _,exit in pairs(exits) do
    if exit.dir == dir and not checked[exit] then
      return exit
    end
  end
end

function TRANSFORMER.process(sectorinfo, params)
  local map = params['map']
  local ox, oy = unpack(params['offset'])
  local player_x, player_y = unpack(params['player-pos'])
  local mw, mh = sectorinfo.grid.getMargins()

  local checked = {}
  for y = 0, map.height - 1 do
    for x = 0, map.width - 1 do
      local real_x, real_y = 1 + mw + ox + x, 1 + mh + oy + y
      local raw = map.data[1 + y * map.width + x]
      local fill = PALETTE[raw]
      sectorinfo.grid.set(real_x, real_y, fill)
      if _EXIT[fill] then
        local exit = _findExitByDir(sectorinfo.exits, _EXIT[fill], checked)
        if exit then
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
  for _, drop_spec in ipairs(params['drops']) do
    local pos = drop_spec['pos']
    local x, y = mw + ox + pos[1], mh + oy + pos[2]
    table.insert(drops[y][x], drop_spec['drop-specname'])
  end
  sectorinfo.drops = drops

  local encounters = {}
  for i, encounter_spec in ipairs(params['encounters']) do
    local pos = encounter_spec['pos']
    local x, y = mw + ox + pos[1], mh + oy + pos[2]
    local encounter = {
      creature = { encounter_spec['actor-specname'],
                   encounter_spec['body-specname'] },
      pos = { y, x } -- EXPECTS [i,j], see sector builder
    }
    encounters[i] = encounter
  end
  sectorinfo.encounters = encounters

  sectorinfo.player_pos = { mh + oy + player_y, mw + ox + player_x }

  return sectorinfo
end

return TRANSFORMER

