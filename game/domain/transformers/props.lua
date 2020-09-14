
local RANDOM      = require 'common.random'
local SCHEMATICS  = require 'domain.definitions.schematics'

local transformer = {}

transformer.schema = {
  { id = 'recipes', name = "Prop specifications", type = 'array',
    schema = {
      { id = 'bodyspec', name = "Body Specification", type = 'enum',
        options = 'domains.body' },
      { id = 'min', name = "Minimum number of clusters", type = 'integer',
        range = {1} },
      { id = 'max', name = "Maximum number of clusters", type = 'integer',
        range = {1} },
      { id = 'growth', name = "Cluster growth chance", type = 'integer',
        range = {0,99} },
    } }
}

local MAX_TRIES = 20

local function _hash(i,j)
  return ("%s:%s"):format(i,j)
end

local function _getRandomPosition(grid, used, mini, minj, maxi, maxj)
  local bounds = { grid.getRange() }
  minj, maxj = math.max(minj, bounds[1]), math.min(maxj, bounds[2])
  mini, maxi = math.max(mini, bounds[3]), math.min(maxi, bounds[4])
  local i, j
  local ok = false
  for _ = 1, MAX_TRIES do
    i = RANDOM.generate(mini, maxi)
    j = RANDOM.generate(minj, maxj)
    if grid.get(j,i) == SCHEMATICS.FLOOR and not used[_hash(i,j)] then
      ok = true
      break
    end
  end
  if ok then
    return i, j
  end
end

local function _growBounds(mini, minj, maxi, maxj, i, j)
   mini, maxi = math.min(mini, i - 1), math.max(maxi, i + 1)
   minj, maxj = math.min(minj, j - 1), math.max(maxj, j + 1)
   return mini, minj, maxi, maxj
end

function transformer.process(sectorinfo, params)
  local grid = sectorinfo.grid
  local recipes = params.recipes
  local encounters = sectorinfo.encounters or {}
  local used = {}
  for _, encounter in ipairs(encounters) do
    used[_hash(unpack(encounter.pos))] = true
  end
  for _, recipe in ipairs(recipes) do
    local total = RANDOM.generate(recipe.min, recipe.max)
    for _=1,total do
      local minj, maxj, mini, maxi = grid.getRange()
      local i, j = _getRandomPosition(grid, used, mini, minj, maxi, maxj)
      mini, minj, maxi, maxj = _growBounds(i, j, i, j, i, j)
      repeat
        local grow = false
        local encounter = {}
        encounter.creature = { nil, recipe.bodyspec }
        encounter.pos = {i,j}
        used[_hash(i,j)] = true
        table.insert(encounters, encounter)
        local rng = RANDOM.generate(1, 100)
        if rng <= recipe.growth then
          i, j = _getRandomPosition(grid, used, mini, minj, maxi, maxj)
          if j and j then
            grow = true
            mini, minj, maxi, maxj = _growBounds(mini, minj, maxi, maxj, i, j)
          end
        end
      until not grow
    end
  end
  sectorinfo.encounters = encounters
  return sectorinfo
end

return transformer

