
local RANDOM = require 'common.random'
local SCHEMATICS = require 'definitions.schematics'

local transformer = {}

transformer.schema = {
  { id = 'n', name = "No. of exits", type = 'integer', range = {1} }
}

function transformer.process(sectorinfo, params)
  local _sectorgrid = sectorinfo.grid
  local n = params.n

  local function getPossibleExits()
    local possible_exits = {}
    for x, y, tile in _sectorgrid.iterate() do
      if tile == SCHEMATICS.FLOOR then
        if _sectorgrid.get(x + 1, y) == SCHEMATICS.FLOOR and
           _sectorgrid.get(x - 1, y) == SCHEMATICS.FLOOR and
           _sectorgrid.get(x, y + 1) == SCHEMATICS.FLOOR and
           _sectorgrid.get(x, y - 1) == SCHEMATICS.FLOOR then
          table.insert(possible_exits, {x, y})
        end
      end
    end
    return possible_exits
  end

  local function getRandomExits(possible_exits)
    local exits = {}
    for i = 1, n do
      local idx = RANDOM.interval(1, #possible_exits)
      table.insert(exits, possible_exits[idx])
    end
    return exits
  end

  local function setExits(exits)
    for i, exit in ipairs(exits) do
      local x, y = exit[1], exit[2]
      _sectorgrid.set(x, y, SCHEMATICS.EXIT)
    end
  end

  sectorinfo.exits = getRandomExits(getPossibleExits())
  setExits(sectorinfo.exits)
  return sectorinfo
end

return transformer

