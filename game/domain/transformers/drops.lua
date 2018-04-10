
local RANDOM = require 'common.random'
local SCHEMATICS = require 'domain.definitions.schematics'

local _RATE_MAX = 100
local _FOOD = 'food'

local transformer = {}

transformer.schema = {
  { id = 'droprate', name = "Food Drop Rate", type = 'integer',
    range = {0, _RATE_MAX} },
}

function transformer.process(sectorinfo, params)
  local grid = sectorinfo.grid
  local droprate = params.droprate

  local drops = {}
  for j, i, tile in grid.iterate() do
    drops[i] = drops[i] or {}
    drops[i][j] = {}
    if tile == SCHEMATICS.FLOOR and RANDOM.generate(_RATE_MAX) <= droprate then
      printf("tile chosen: [%d, %d] '%s'", i, j, tile)
      table.insert(drops[i][j], _FOOD)
    end
  end

  sectorinfo.drops = drops
  return sectorinfo
end

return transformer

