
local RANDOM = require 'common.random'

local ROUTEBUILDER = {}

function ROUTEBUILDER.build (route_id)
  RANDOM.setSeed(RANDOM.generateSeed())
  return {
    version = VERSION,
    charname = "Banana",
    route_id = route_id,
    next_id = 1,
    rng_seed = RANDOM.getSeed(),
    rng_state = RANDOM.getState(),
    actors = {},
    sectors = {},
  }
end

return ROUTEBUILDER

