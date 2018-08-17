
local MANEUVERS  = require 'lux.pack' 'domain.maneuver'
local ACTIONDEFS = require 'domain.definitions.action'
local FindTarget = require 'domain.behaviors.helpers.findtarget'
local FindPath   = require 'domain.behaviors.helpers.findpath'
local RandomWalk = require 'domain.behaviors.helpers.randomwalk'

local _USE_SIGNATURE = ACTIONDEFS.USE_SIGNATURE
local _MOVE          = ACTIONDEFS.MOVE

return function (actor)
  local sector = actor:getSector()
  local behaviors = sector:getRoute().getBehaviors()
  local ai = behaviors.getAI(actor) or behaviors.newAI(actor)
  local i, j = actor:getPos()

  local target = ai.target
  local target_pos = ai.target_pos

  -- if i don't have a target or it is dead, i'll look for one
  if not target or target:isDead() then
    target = FindTarget.getTarget(actor)
  end

  if target then
    -- if i have a target, can i see it?
    if actor:canSee(target) then
      -- if so, lock on to it
      local k, l = target:getPos()
      target_pos = { k, l }
    else
      -- if not, lose the target, but not its position
      target = false
    end
  elseif target_pos then
    -- if i don't have a target, but i have its last position...
    -- ...am i in the target's position?
    local k, l = unpack(target_pos)
    if i == k and l == j then
      -- if so, then i lost them completely
      target_pos = false
    end
  end

  -- update AI state
  ai.target = target
  ai.target_pos = target_pos

  -- if i have a position targetted
  if target_pos then
    -- ...if i have a target, then try to attack!
    local inputs = { pos = target_pos }
    if target and MANEUVERS[_USE_SIGNATURE].validate(actor, inputs) then
      return _USE_SIGNATURE, inputs
    end
    -- ...if i can't see or reach them, then at least chase it!
    local next_step = FindPath.getNextStep({i, j}, target_pos, sector)
    inputs.pos = next_step
    if next_step and MANEUVERS[_MOVE].validate(actor, inputs) then
      return _MOVE, inputs
    end
  end

  -- i don't have targets or any clue to my last target's position
  return RandomWalk.execute(actor)
end

