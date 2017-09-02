
-- dependencies
local DB = require 'database'
local RANDOM = require 'common.random'
local TRANSFORMERS = require 'lux.pack' 'domain.transformers'
local SectorGrid = require 'domain.transformers.helpers.sectorgrid'

-- seed value
local _seed = RANDOM.generateSeed()
RANDOM.setSeed(_seed)

-- generation of sector, pretty straightforward
local SPEC = DB.loadSpec("sector", "sector01")
local W, H = SPEC.width, SPEC.height
local MW = SPEC["margin-width"]
local MH = SPEC["margin-height"]

local function generate()
  local grid = SectorGrid(W, H, MW, MH)
  for _, specs in ipairs(SPEC.transformers) do
    TRANSFORMERS[specs.typename].process(grid, specs)
  end
  print(grid)
  return grid
end

-- generation of sector with controlled seeds
return function(s)
  local seed = s or RANDOM.generateSeed()
  RANDOM.setSeed(seed)
  print("SEED:", seed)
  return generate()
end

