
local RANDOM = require 'common.random'
local SectorGrid = require 'domain.transformers.helpers.sectorgrid'
local SCHEMATICS = require 'domain.definitions.schematics'

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

  -- setup
  do
    for n = 1, params.count do
      local x, y
      repeat
        x = RANDOM.generate(min_x, max_x)
        y = RANDOM.generate(min_y, max_y)
      until from_grid.get(x, y) == SCHEMATICS.WALL
      to_grid.set(x, y, SCHEMATICS.NAUGHT)
    end
  end

  print("START")
  print(to_grid)
  from_grid, to_grid = to_grid, from_grid

  -- iterations
  do
    for n = 1, params.iter do
      for x, y, tile in from_grid.iterate() do
        local count = 0
        for dx = -1, 1 do
          for dy = -1, 1 do
            local nx, ny = x+dx, y+dx
            if (x ~= ny or y ~= ny) then
              if from_grid.get(nx, ny) == SCHEMATICS.NAUGHT then
                count = count + 1
              end
            end
          end
        end
        if count >= 1 and count <= 8 and tile == SCHEMATICS.WALL then
          to_grid.set(x, y, SCHEMATICS.NAUGHT)
        elseif tile ~= SCHEMATICS.NAUGHT then
          to_grid.set(x, y, from_grid.get(x, y))
        end
      end
      print("STEP", n)
      print(to_grid)
      to_grid, from_grid = from_grid, to_grid
    end
  end

  print("DONE")
  print(to_grid)
  sectorinfo.grid = to_grid
  return sectorinfo
end

return transformer

