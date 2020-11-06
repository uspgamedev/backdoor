
local RANDOM = require 'common.random'
local SectorGrid = require 'domain.transformers.helpers.sectorgrid'
local SCHEMATICS = require 'domain.definitions.schematics'
local DIR        = require 'domain.definitions.dir'

local transformer = {}

transformer.schema = {
  { id = 'count', name = "Initial pokes", type = 'integer', range = {1} },
  { id = 'tiletype', name = "Tile", type = 'enum', options = SCHEMATICS },
  { id = 'window', name = "Window size", type = 'integer', range = {1} },
  { id = 'threshold', name = "Threshold", type = 'integer', range = {1} },
  { id = 'iter', name = "Iterations", type = 'integer', range = {1} },
}

function transformer.process(sectorinfo, params)
  local from_grid = sectorinfo.grid
  local to_grid = SectorGrid:copy(from_grid)
  local tiletype = SCHEMATICS[params.tiletype]

  local w, h = from_grid.getDim()
  local mw, mh = from_grid.getMargins()
  local min_x, min_y = mw + 1, mh + 1
  local max_x, max_y = w - min_x, h - min_y

  do
    for n = 1, params.count do
      local x, y
      x = RANDOM.generate(min_x, max_x)
      y = RANDOM.generate(min_y, max_y)
      to_grid.set(x, y, tiletype)
    end
  end
  from_grid, to_grid = to_grid, from_grid

  -- iterations
  do
    for n = 1, params.iter do
      for x, y, tile in from_grid.iterate() do
        local count = 0
        local d = params.window
        for nx = x - d, x + d do
          for ny = y - d, y + d do
            if from_grid.get(nx, ny) == tiletype then
              count = count + 1
            end
          end
        end
        if count >= params.threshold and tile ~= tiletype then
          to_grid.set(x, y, tiletype)
        else
          to_grid.set(x, y, tile)
        end
      end
      to_grid, from_grid = from_grid, to_grid
    end
  end

  sectorinfo.grid = to_grid
  return sectorinfo
end

return transformer

