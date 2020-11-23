
local RANDOM      = require 'common.random'
local SCHEMATICS  = require 'domain.definitions.schematics'

local TRANSFORMER = {}

TRANSFORMER.schema = {
  { id = 'min', name = "Minimum number of encounters", type = 'integer',
    range = {1} },
  { id = 'max', name = "Maximum number of encounters", type = 'integer',
    range = {1} },
  { id = 'upgrade_power', name = "Upgrade Power", type = 'integer',
    range = {10,1000} },
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

function TRANSFORMER.process(sectorinfo, params)
  local grid = sectorinfo.grid
  local recipes = params.recipes
  local encounters = sectorinfo.encounters or {}
  local total = RANDOM.generate(params.min, params.max)
  local used = {}

  for _=1,total do
    local encounter = {}
    local recipe = recipes[RANDOM.generate(1,#recipes)]
    local upgrade_power = math.floor((0.9 + 0.2 * RANDOM.generate())
                                     * params.upgrade_power)
    encounter.upgrade_power = upgrade_power
    encounter.creature = { recipe.actorspec, recipe.bodyspec }
    local minj, maxj, mini, maxi = grid.getRange()
    local i, j
    repeat
      i = RANDOM.generate(mini, maxi)
      j = RANDOM.generate(minj, maxj)
    until grid.get(j,i) == SCHEMATICS.FLOOR and not used[_hash(i,j)]
      and not TRANSFORMER.hasAnyEncountersAt(encounters, i, j)
    encounter.pos = {i,j}
    used[_hash(i,j)] = true
    table.insert(encounters, encounter)
  end
  sectorinfo.encounters = encounters
  return sectorinfo
end

function TRANSFORMER.hasAnyEncountersAt(encounters, i, j)
  if encounters then
    for _, encounter in ipairs(encounters) do
      if encounter.pos[1] == i and encounter.pos[2] == j then
        return true
      end
    end
  end
  return false
end

return TRANSFORMER

