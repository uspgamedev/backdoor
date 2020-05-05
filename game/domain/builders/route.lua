
local RUNFLAGS        = require 'infra.runflags'
local RANDOM          = require 'common.random'
local IDGenerator     = require 'common.idgenerator'
local SECTORS_BUILDER = require 'domain.builders.sectors'

local BUILDER = {}

local _ROUTE_NAMES = {
  "Banana",
  "Kiwi",
  "Omar",
  "Orange",
  "Front Door",
  "Longsword",
  "Jennifer",
  "Evil Dragon",
  "Jacekt",
  "Pants",
  "Green",
  "Boots",
  "Pudding",
  "Cake",
  "Fox",
  "OwO",
  "Nope",
  "Hector",
  "Black",
  "Glass",
  "January",
  "Hallow",
  "Hollow",
  "Skeleton",
  "Ghost",
  "Sord",
  "Juniper",
  "Corgi",
  "Dog",
  "Cat"
}

function BUILDER.build(route_id, player_info)
  local idgenerator = IDGenerator()
  local data = {}
  if RUNFLAGS.SAFESEED then
    -- if we have to debug rng corner cases that are not from route's rng
    RANDOM.setSafeSeed(RUNFLAGS.SAFESEED)
  end
  RANDOM.setSeed(RUNFLAGS.SEED or RANDOM.generateSeed())
  player_info.name = _ROUTE_NAMES[RANDOM.safeGenerate(#_ROUTE_NAMES)]
  data.version = VERSION
  data.id = route_id
  data.rng_seed = RANDOM.getSeed()
  data.rng_state = RANDOM.getState()
  local sectors, first_sector = SECTORS_BUILDER.build(idgenerator, player_info)
  assert(first_sector, "No initial sector.")
  data.sectors = sectors
  data.next_id = idgenerator.getNextID()
  data.current_sector_id = first_sector.id
  data.player_name = player_info.name
  local last = #first_sector.actors
  data.player_id = first_sector.actors[last].id
  data.behaviors = { ai = {} }
  printf("Generated %s...", route_id)
  printf("GLOBAL RNG seed: %d", RANDOM.getSafeSeed())
  printf("ROUTE RNG seed: %d", data.rng_seed)
  printf("ROUTE RNG state: %d", data.rng_state)
  return data
end

return BUILDER

