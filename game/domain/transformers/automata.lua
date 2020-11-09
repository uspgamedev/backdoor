
local SectorGrid = require 'domain.transformers.helpers.sectorgrid'
local SCHEMATICS = require 'domain.definitions.schematics'

local TRANSFORMER = {}

TRANSFORMER.schema = {
  {
    id = 'patterns', name = "Pattern", type = 'array',
    schema = {
      { id = 'iter', name = "Iterations", type = 'integer', range = {1} },
      { id = 'fill', name = "Fill Tile", type = 'enum', options = SCHEMATICS },
      { id = 'erase', name = "Erase Tile", type = 'enum', options = SCHEMATICS },
      {
        id = 'checks', name = "Check", type = 'array',
        schema = {
          { id = 'radius', name = "Radius", type = 'integer',
            range = {1} },
          { id = 'comp_op', name = "Comparation Type", type = 'enum',
            options = { 'LESS_OR_EQ', 'GREATER_OR_EQ' } },
          { id = 'threshold', name = "Threshold", type = 'integer',
            range = {1} },
        }
      }
    }
  }
}

TRANSFORMER.CMP = {
  LESS_OR_EQ = function (x1, x2) return x1 <= x2 end,
  GREATER_OR_EQ = function (x1, x2) return x1 >= x2 end
}

function TRANSFORMER.process(sectorinfo, params)
  local from_grid = sectorinfo.grid
  local to_grid = SectorGrid:copy(from_grid)

  for _, pattern in ipairs(params['patterns']) do
    local fill_tile = SCHEMATICS[pattern['fill']]
    local erase_tile = SCHEMATICS[pattern['erase']]
    for _ = 1, pattern['iter'] do
      for x, y, _ in from_grid.iterate() do
        if from_grid.isInsideMargins(x, y) then
          to_grid.set(x, y, erase_tile)
          for _, check in ipairs(pattern['checks']) do
            local radius = check['radius']
            local threshold = check['threshold']
            local count = TRANSFORMER.count(from_grid, x, y, fill_tile, radius)
            if TRANSFORMER.CMP[check['comp_op']](count, threshold) then
              to_grid.set(x, y, fill_tile)
              break
            end
          end
        end
      end
      to_grid, from_grid = from_grid, to_grid
    end
  end

  sectorinfo.grid = to_grid
  return sectorinfo
end

function TRANSFORMER.count(grid, x, y, tile, radius)
  local count = 0
  for ty = y - radius, y + radius do
    for tx = x - radius, x + radius do
      if grid.get(tx, ty) == tile then
        count = count + 1
      end
    end
  end
  return count
end

return TRANSFORMER

