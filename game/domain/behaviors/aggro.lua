
local TILE       = require 'common.tile'
local Action     = require 'domain.action'
local MANEUVERS  = require 'lux.pack' 'domain.maneuver'
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

  if target then
    local inputs = { pos = { target:getPos() } }
    if MANEUVERS[ACTIONDEFS.USE_SIGNATURE].validate(actor, inputs) then
      -- attack if close!
      return ACTIONDEFS.USE_SIGNATURE, inputs
    else
      -- chase if far away!
      inputs.pos = FindPath.getNextStep({i, j}, inputs.pos, sector)
      if inputs.pos and MANEUVERS[ACTIONDEFS.MOVE].validate(actor, inputs) then
        return ACTIONDEFS.MOVE, inputs
      end
    end
  end

  -- there are valid targets, but i can't reach them
  return RandomWalk.execute(actor)
end

