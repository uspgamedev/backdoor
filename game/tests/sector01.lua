
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

local function generate()
  local sectorinfo = {}
  for _, specs in ipairs(SPEC.transformers) do
    sectorinfo = TRANSFORMERS[specs.typename].process(sectorinfo, specs)
  end
  print(sectorinfo.grid)
  return sectorinfo
end

-- generation of sector with controlled seeds
return function(s)
  local seed = s or RANDOM.generateSeed()
  RANDOM.setSeed(seed)
  print("SEED:", seed)
  return generate()
end

