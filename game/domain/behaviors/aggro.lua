
local TILE       = require 'common.tile'
local Action     = require 'domain.action'
local ACTIONDEFS = require 'domain.definitions.action'
local FindPath   = require 'domain.behaviors.helpers.findpath'

return function (actor)
  local target, dist
  local sector = actor:getBody():getSector()
  local i, j = actor:getPos()

  -- create list of opponents
  for _,opponent in sector:iterateActors() do
    if opponent:isPlayer() then
      local k, l = opponent:getPos()
      local d = TILE.dist(i, j, k, l)
      if not target or not dist or d < dist then
        target = opponent
        dist = d
      end
    end
  end

  if dist == 1 then
    -- attack if close!
    return ACTIONDEFS.USE_SIGNATURE, { pos = {target:getPos()} }
  elseif dist <= 8 then
    -- chase if far away!
    local pos = FindPath.getNextStep({i,j}, {target:getPos()}, sector)
    if pos then
      return ACTIONDEFS.MOVE, { pos = pos }
    end
  end

  return ACTIONDEFS.IDLE, {}
end

