
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
  RANDOM.setSeed(RANDOM.generateSeed())
  local idgenerator = IDGenerator()
  local data = {}
  player_info.name = _ROUTE_NAMES[RANDOM.safeGenerate(#_ROUTE_NAMES)]
  data.version = VERSION
  data.id = route_id
  data.rng_seed = RANDOM.getSeed()
  data.rng_state = RANDOM.getState()
  data.sectors = SECTORS_BUILDER.build(idgenerator, player_info)
  data.next_id = idgenerator.getNextID()
  local first_sector = data.sectors[#data.sectors]
  data.current_sector_id = first_sector.id
  data.player_name = player_info.name
  data.player_id = first_sector.actors[1].id
  data.behaviors = { ai = {} }
  return data
end

return BUILDER

