local ADJACENCY = require 'view.helpers.adjacency'
local DIR       = require 'domain.definitions.dir'

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

function LONG_WALK.continue(hud)
  local dir = hud.long_walk
  dir = DIR[dir]
  local i, j = hud.route.getControlledActor():getPos()
  i, j = i+dir[1], j+dir[2]
  if not hud.route.getCurrentSector():isValid(i,j) then
    return false
  end
  if hud.alert then
    hud.alert = false
    return false
  end

  local hostile_bodies = hud.route.getControlledActor():getHostileBodies()

  return not (#hostile_bodies > 0 or
              ADJACENCY.update(hud.adjacency, hud.route, dir))
end

return LONG_WALK
