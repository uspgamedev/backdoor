
local RANDOM = require 'common.random'
local SCHEMATICS = require 'domain.definitions.schematics'

local transformer = {}

transformer.schema = {
  { id = 'threshold', name = "Threshold spacing", type = 'integer',
    range = {0} },
  { id = 'distance', name = "Distance between exits", type = 'integer',
    range = {1} },
}

local FLOOR_THRESHOLD = 1
local EXIT_THRESHOLD = 1

local function _hasSpaceForExit(grid, x, y)
  local f = SCHEMATICS.FLOOR
  for dx = -FLOOR_THRESHOLD, FLOOR_THRESHOLD do
    for dy = -FLOOR_THRESHOLD, FLOOR_THRESHOLD do
      local tx, ty = dx + x, dy + y
      local tile = grid.get(tx, ty)
      -- verify it's a position surrounded by floors and not a single exit
      if tile ~= f then return false end
    end
  end
  return true
end

local function _hasNoExitNearby(grid, x, y)
  local e = SCHEMATICS.EXIT
  for dx = -EXIT_THRESHOLD, EXIT_THRESHOLD, 1 do
    for dy = -EXIT_THRESHOLD, EXIT_THRESHOLD, 1 do
      local tx, ty = dx + x, dy + y
      local tile = grid.get(tx, ty)
      -- verify it's a position surrounded by floors and not a single exit
      if tile == e then return false end
    end
  end
  return true
end

local function _isPossibleExit(grid, x, y)
  return _hasSpaceForExit(grid, x, y) and _hasNoExitNearby(grid, x, y)
end

function transformer.process(sectorinfo, params)
  local sectorgrid = sectorinfo.grid
  local exits_specs = sectorinfo.exits

  local possible_exits = {}

  FLOOR_THRESHOLD = params.threshold or FLOOR_THRESHOLD
  EXIT_THRESHOLD = params.distance or EXIT_THRESHOLD

  -- construct list of possible exits
  do
    for x, y, tile in sectorgrid.iterate() do
      if _isPossibleExit(sectorgrid, x, y) then
        table.insert(possible_exits, {y, x})
      end
    end
  end

  -- get a number of random possible exits from that list
  do
    for id, exit in pairs(exits_specs) do
      local i, j
      repeat
        local COUNT = #possible_exits
        if COUNT == 1 then
          -- if there is only one last possible exit, check it:
          i, j = unpack(possible_exits[1])
          -- if it's not a good position, tough luck, break it up
          if not _isPossibleExit(sectorgrid, j, i) then
            return error("Not enough possible exits. Invalid sector.")
          end
        else
          -- if there are many possible exits, get a random one:
          local idx = RANDOM.generate(1, COUNT)
          i, j = unpack(possible_exits[idx])
          -- remove found position from list of possible exits
          table.remove(possible_exits, idx)
        end
        -- repeat until you find a position that:
        -- > is not an exit or around another exit
      until _isPossibleExit(sectorgrid, j, i)
      exit.pos = {i, j}
      -- add exit info to sectorinfo
      -- and set and exit tile on the sectorgrid
      sectorgrid.set(j, i, SCHEMATICS.EXIT)
    end
  end

  return sectorinfo
end

return transformer

