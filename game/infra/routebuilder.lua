
local ROUTEBUILDER = {}

function ROUTEBUILDER.build (route_id)
  return {
    version = VERSION,
    charname = "Banana",
    route_id = route_id,
    next_id = 1,
    seed = tonumber(tostring(os.time()):sub(-7):reverse()),
    actors = {},
    sectors = {},
  }
end

return ROUTEBUILDER

