local ADJACENCY = require 'view.helpers.adjacency'

local LONG_WALK = {}

function LONG_WALK.isAllowed(hud)
  local hostile_bodies = hud.route.getControlledActor():getHostileBodies()
  return (not hud.long_walk) and #hostile_bodies == 0
end

function LONG_WALK.start(hud, dir)
  ADJACENCY.unset(hud.adjacency)
  hud.long_walk = dir
  hud.alert = false
end

return LONG_WALK
