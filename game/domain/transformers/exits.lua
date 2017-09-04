
local RANDOM = require 'common.random'
local SCHEMATICS = require 'domain.definitions.schematics'

local transformer = {}

transformer.schema = {
  { id = 'exits', name = "Exits", type = 'array',
    schema = {
      id = "target_specname", name = "Target Sector Spec", type = 'enum',
      options = "sector"
    }
  },
}

function transformer.process(sectorinfo, params)
  local _sectorgrid = sectorinfo.grid
  local _exits = params.exits

  local function getPossibleExits()
    local possible_exits = {}
    for x, y, tile in _sectorgrid.iterate() do
      if tile == SCHEMATICS.FLOOR then
        if _sectorgrid.get(x + 1, y) == SCHEMATICS.FLOOR and
           _sectorgrid.get(x - 1, y) == SCHEMATICS.FLOOR and
           _sectorgrid.get(x, y + 1) == SCHEMATICS.FLOOR and
           _sectorgrid.get(x, y - 1) == SCHEMATICS.FLOOR then
          table.insert(possible_exits, {y, x})
        end
      end
    end
    return possible_exits
  end

  local function getRandomExits(possible_exits)
    local N = #_exits
    local exits = {}
    for i = 1, N do
      local idx = RANDOM.generate(1, #possible_exits)
      table.insert(exits, {
        pos = possible_exits[idx],
        target_specname = _exits[i].target_specname
      })
    end
    return exits
  end

  local function setExits(exits)
    for _,exit in ipairs(exits) do
      local x, y = exit.pos[2], exit.pos[1]
      _sectorgrid.set(x, y, SCHEMATICS.EXIT)
    end
  end

  sectorinfo.exits = getRandomExits(getPossibleExits())
  setExits(sectorinfo.exits)
  return sectorinfo
end

return transformer

