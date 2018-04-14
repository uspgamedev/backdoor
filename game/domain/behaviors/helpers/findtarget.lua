
local TILE = require 'common.tile'

local FindTarget = {}

function FindTarget.getTarget(actor)
  local target, dist
  local visible_bodies = actor:getVisibleBodies()
  for body_id in pairs(visible_bodies) do
    local opponent = Util.findId(body_id)
    if opponent and opponent:getFaction() ~= actor:getBody():getFaction() then
      local k, l = opponent:getPos()
      local d = TILE.dist(i, j, k, l)
      if not target or not dist or d < dist then
        target = opponent
        dist = d
      end
    end
  end
  return target
end

return FindTarget

