
local RANDOM      = require 'common.random'
local SCHEMATICS  = require 'domain.definitions.schematics'

local transformer = {}

transformer.schema = {
  { id = 'min', name = "Minimum number of encounters", type = 'integer',
    range = {1} },
  { id = 'max', name = "Maximum number of encounters", type = 'integer',
    range = {1} },
  { id = 'recipes', name = "Encounter recipe", type = 'array',
    schema = {
      { id = 'actorspec', name = "Actor Specification", type = 'enum',
        options = 'domains.actor' },
      { id = 'bodyspec', name = "Body Specification", type = 'enum',
        options = 'domains.body' },
    } }
}

local function _hash(i,j)
  return ("%s:%s"):format(i,j)
end

function transformer.process(sectorinfo, params)
  local grid = sectorinfo.grid
  local recipes = params.recipes
  local encounters = {}
  local total = RANDOM.generate(params.min, params.max)
  local used = {}

  for i=1,total do
    local encounter = {}
    local recipe = recipes[RANDOM.generate(1,#recipes)]
    encounter.monster = { recipe.actorspec, recipe.bodyspec }
    local minj, maxj, mini, maxi = grid.getRange()
    local i, j
    repeat
      i = RANDOM.generate(mini, maxi)
      j = RANDOM.generate(minj, maxj)
    until grid.get(j,i) == SCHEMATICS.FLOOR and not used[_hash(i,j)]
    encounter.pos = {i,j}
    used[_hash(i,j)] = true
    table.insert(encounters, encounter)
  end
  sectorinfo.encounters = encounters
  return sectorinfo
end

return transformer

