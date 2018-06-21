
local RANDOM = require 'common.random'
local SCHEMATICS = require 'domain.definitions.schematics'

local transformer = {}

transformer.schema = {
  { id = 'threshold', name = "Threshold spacing", type = 'integer',
    range = {0} },
  { id = 'min', name = "Minimum number of altars", type = 'integer',
    range = {0} },
  { id = 'max', name = "Maximum number of altars", type = 'integer',
    range = {0} },
}

local FLOOR_THRESHOLD = 1

local function _canPlaceAltar(grid, x, y)
  local f = SCHEMATICS.FLOOR
  for dx = -FLOOR_THRESHOLD, FLOOR_THRESHOLD do
    for dy = -FLOOR_THRESHOLD, FLOOR_THRESHOLD do
      local tx, ty = dx + x, dy + y
      local tile = grid.get(tx, ty)
      -- verify it's a position surrounded by floors
      if tile ~= f then return false end
    end
  end
  return true
end

function transformer.process(sectorinfo, params)
  local sectorgrid = sectorinfo.grid
  local altars_min, altars_max = params.min, params.max
  
  local possible_altars = {}

  FLOOR_THRESHOLD = params.threshold or FLOOR_THRESHOLD
  
  -- construct list of possible altars
  do
    for x, y, tile in sectorgrid.iterate() do
      if _canPlaceAltar(sectorgrid, x, y) then
        table.insert(possible_altars, {y, x})
      end
    end
  end

  local number_altars = RANDOM.generate(altars_min, altars_max)
  
  for i = 1, number_altars do
    local size = #possible_altars
    if size <= 0 then break end
    local idx = RANDOM.generate(1,size)
    local pos = table.remove(possible_altars, idx)
    sectorgrid.set(pos[2], pos[1], SCHEMATICS.ALTAR)  
  end

  return sectorinfo
end

return transformer

