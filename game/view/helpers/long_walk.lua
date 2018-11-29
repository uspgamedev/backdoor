local Adjacency = require 'view.helpers.adjacency'

local funcs = {}

function funcs.isAllowed(hud)
  local hostile_bodies = hud.route.getControlledActor():getHostileBodies()
  return (not hud.long_walk) and #hostile_bodies == 0
end

function funcs.start(hud, dir)
  Adjacency.unset(hud.adjacency)
  hud.long_walk = dir
  hud.alert = false
end

return funcs
