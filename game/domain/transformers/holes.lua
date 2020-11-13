
local RANDOM = require 'common.random'
local SectorGrid = require 'domain.transformers.helpers.sectorgrid'
local SCHEMATICS = require 'domain.definitions.schematics'
local DIR        = require 'domain.definitions.dir'

local transformer = {}

transformer.schema = {
  { id = 'count', name = "Initial", type = 'integer', range = {1} },
  { id = 'iter', name = "Iterations", type = 'integer', range = {1} },
}

function transformer.process(sectorinfo, params)
  local from_grid = sectorinfo.grid
  local to_grid = SectorGrid:copy(from_grid)

  local w, h = from_grid.getDim()
  local mw, mh = from_grid.getMargins()
  local min_x, min_y = mw + 1, mh + 1
  local max_x, max_y = w - min_x, h - min_y

  do
    for _ = 1, params.count do
      local x, y
      repeat
        x = RANDOM.generate(min_x, max_x)
        y = RANDOM.generate(min_y, max_y)
      until from_grid.get(x, y) == SCHEMATICS.WALL
      to_grid.set(x, y, SCHEMATICS.NAUGHT)
    end
  end
  from_grid, to_grid = to_grid, from_grid

  -- iterations
  do
    for _ = 1, params.iter do
      for x, y, tile in from_grid.iterate() do
        local count = 0
        for _,dir in ipairs(DIR) do
          local dx, dy = unpack(DIR[dir])
          local nx, ny = x+dx, y+dy
          if (x ~= ny or y ~= ny) then
            if from_grid.get(nx, ny) == SCHEMATICS.NAUGHT then
              count = count + 1
            end
          end
        end
        if count > 3 and tile == SCHEMATICS.WALL then
          if RANDOM.generate() > .5 then
            to_grid.set(x, y, SCHEMATICS.NAUGHT)
          end
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

