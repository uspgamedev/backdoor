
local RANDOM = require 'common.random'

local ROUTEBUILDER = {}

function ROUTEBUILDER.build (route_id)
  RANDOM.setSeed(RANDOM.generateSeed())
  local data = {}
  data.version = VERSION
  data.charname = "Banana"
  data.route_id = route_id
  data.next_id = 1
  data.rng_seed = RANDOM.getSeed()
  data.rng_state = RANDOM.getState()
  data.actors = {}
  data.sectors = {}
  return data
end

return ROUTEBUILDER

