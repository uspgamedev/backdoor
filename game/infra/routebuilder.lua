
local RANDOM = require 'common.random'

local ROUTEBUILDER = {}

function ROUTEBUILDER.build (route_id)
  return {
    version = VERSION,
    charname = "Banana",
    route_id = route_id,
    next_id = 1,
    seed = RANDOM.generateSeed(),
    actors = {},
    sectors = {},
  }
end

return ROUTEBUILDER

