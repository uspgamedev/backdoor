
local RANDOM = require 'common.random'
local SCHEMATICS = require 'domain.definitions.schematics'

local _RATE_MAX = 256

local transformer = {}

transformer.schema = {
  { id = 'drop-info', type = 'description',
    info = ("Chance of drop in a given "
            .. "tile is [Drop Rate] / %d"):format(_RATE_MAX)
  },
  { id = 'drops', name = 'Drop Spec', type = 'array',
    schema = {
      { id = 'droptype', name = "Drop Type", type = 'enum',
        options = 'domains.drop' },
      { id = 'droprate', name = "Drop Rate", type = 'integer',
        range = {0, _RATE_MAX}, },
    },
  },
}

function transformer.process(sectorinfo, params)
  local grid = sectorinfo.grid

  local drops = {}
  for _,dropspec in ipairs(params.drops) do
    local droprate = dropspec.droprate
    local droptype = dropspec.droptype
    for j, i, tile in grid.iterate() do
      drops[i] = drops[i] or {}
      drops[i][j] = drops[i][j] or {}
      if tile == SCHEMATICS.FLOOR and
         RANDOM.generate(_RATE_MAX) <= droprate then
        table.insert(drops[i][j], droptype)
      end
    end
  end

  sectorinfo.drops = drops
  return sectorinfo
end

return transformer

