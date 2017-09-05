
local RANDOM      = require 'common.random'
local SCHEMATICS  = require 'domain.definitions.schematics'

local transformer = {}

transformer.schema = {
  {
  },
}

function transformer.process(sectorinfo, params)
  local grid = sectorinfo.grid
  local encounters = {}

  for i=1,20 do
    local encounter = {}
    encounter.monster = { 'dumb', 'slime' }
    local minj, maxj, mini, maxi = grid.getRange()
    local i, j
    repeat
      i = RANDOM.generate(mini, maxi)
      j = RANDOM.generate(minj, maxj)
    until grid.get(j,i) == SCHEMATICS.FLOOR
    encounter.pos = {i,j}
    table.insert(encounters, encounter)
  end
  sectorinfo.encounters = encounters
  return sectorinfo
end

return transformer

