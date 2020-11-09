
local SCHEMATICS = require 'domain.definitions.schematics'

local TRANSFORMER = {}

TRANSFORMER.schema = {}

TRANSFORMER.DIRS = {
  { dx = 0, dy = -1 },
  { dx = 1, dy = 0 },
  { dx = 0, dy = 1 },
  { dx = -1, dy = 0 },
}

function TRANSFORMER.process(sectorinfo, _)
  local grid = sectorinfo.grid
  local regions = {}
  local n = 0
  local checked = {}

  for x, y, tile in grid.iterate() do
    local id = TRANSFORMER.getId(grid, x, y)
    if tile == SCHEMATICS.FLOOR and not checked[id] then
      local region = TRANSFORMER.flood(grid, x, y, checked)
      n = n + 1
      regions[n] = region
    end
  end

  assert(n > 0, "No walkable regions!")

  if n > 1 then
    local largest = nil
    local largest_size = -1
    for _, region in ipairs(regions) do
      if region.size > largest_size then
        largest_size = region.size
        largest = region
      end
    end
    for _, region in ipairs(regions) do
      if region ~= largest then
        for _, tile in ipairs(region.tiles) do
          grid.set(tile.x, tile.y, SCHEMATICS.WALL)
        end
      end
    end
  end

  return sectorinfo
end

function TRANSFORMER.getId(grid, x, y)
  return grid.getWidth() * (y - 1) + (x - 1)
end

function TRANSFORMER.flood(grid, x, y, checked)
  local queue = require 'lux.common.Queue' (grid.getSize())
  local count = 0
  local tiles = {}
  queue.push({ x = x, y = y })
  while not queue.isEmpty() do
    local tile = queue.pop()
    local id = TRANSFORMER.getId(grid, tile.x, tile.y)
    if not checked[id] and grid.get(tile.x, tile.y) == SCHEMATICS.FLOOR then
      checked[id] = true
      count = count + 1
      tiles[count] = tile
      for _, dir in ipairs(TRANSFORMER.DIRS) do
        local neighbor = { x = tile.x + dir.dx, y = tile.y + dir.dy }
        queue.push(neighbor)
      end
    end
  end
  return {
    tiles = tiles, size = count
  }
end

return TRANSFORMER

