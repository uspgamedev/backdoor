
local TILE       = require 'common.tile'
local Action     = require 'domain.action'
local ACTIONDEFS = require 'domain.definitions.action'
local FindPath   = require 'domain.behaviors.helpers.findpath'
local RandomWalk = require 'domain.behaviors.helpers.random'

return function (actor)
  local target, dist
  local sector = actor:getBody():getSector()
  local i, j = actor:getPos()

  -- i can't see anybody!
  local visible_bodies = actor:getVisibleBodies()

  -- create list of opponents
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

  if not target then
    -- i can't see anybody of opposing faction!
    return RandomWalk.execute(actor)
  elseif dist == 1 then
    -- attack if close!
    return ACTIONDEFS.USE_SIGNATURE, { pos = {target:getPos()} }
  elseif dist <= 8 then
    -- chase if far away!
    local pos = FindPath.getNextStep({i,j}, {target:getPos()}, sector)
    if pos then
      return ACTIONDEFS.MOVE, { pos = pos }
    end
  end

  -- there are valid targets, but i can't reach them
  return RandomWalk.execute(actor)
end

