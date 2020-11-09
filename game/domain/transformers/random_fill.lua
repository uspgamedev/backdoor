
local RANDOM = require 'common.random'
local SCHEMATICS = require 'domain.definitions.schematics'

local transformer = {}

transformer.schema = {
  { id = 'chance', name = "Percentage of filled tiles", type = 'integer',
    range = {1,100} },
  { id = 'tiletype', name = "Tile", type = 'enum', options = SCHEMATICS },
}

function transformer.process(sectorinfo, params)
  local tiletype = SCHEMATICS[params.tiletype]

  for x, y, _ in sectorinfo.grid.iterate() do
    if RANDOM.generate(1, 100) <= params.chance then
      sectorinfo.grid.set(x, y, tiletype)
    end
  end

  return sectorinfo
end

return transformer

