
-- dependencies
local DB = require 'database'
local RANDOM = require 'common.random'
local TRANSFORMERS = require 'lux.pack' 'domain.transformers'
local SectorGrid = require 'domain.transformers.helpers.sectorgrid'

-- seed value
local _seed = RANDOM.generateSeed()
RANDOM.setSeed(_seed)

-- generation of sector, pretty straightforward
local function generate()
  local sectorinfo = {}

  for _,transformer in DB.schemaFor('sector') do
    local spec = DB.loadSpec("sector", "sector01")[transformer.id]
    if spec then
      sectorinfo = TRANSFORMERS[transformer.id].process(sectorinfo, spec)
    end
  end

  print(sectorinfo.grid, sectorinfo.grid:getDim())
  return sectorinfo
end

-- generation of sector with controlled seeds
return function(s)
  local seed = s or RANDOM.generateSeed()
  RANDOM.setSeed(seed)
  print("SEED:", seed)
  return generate()
end

