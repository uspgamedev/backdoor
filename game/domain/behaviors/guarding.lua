
local RANDOM     = require 'common.random'
local MANEUVERS  = require 'lux.pack' 'domain.maneuver'
local ACTIONDEFS = require 'domain.definitions.action'
local FindTarget = require 'domain.behaviors.helpers.findtarget'
local FindPath   = require 'domain.behaviors.helpers.findpath'
local listCardPlays = require 'domain.behaviors.helpers.listcardplays'
local RandomWalk = require 'domain.behaviors.helpers.randomwalk'

local _MOVE          = ACTIONDEFS.MOVE
local _PLAY_CARD     = ACTIONDEFS.PLAY_CARD

return function (actor)
  local sector = actor:getSector()
  local behaviors = sector:getRoute().getBehaviors()
  local ai = behaviors.getAI(actor) or behaviors.newAI(actor)

  local target = ai.target
  local target_pos = ai.target_pos
  local guarding_pos = ai.guarding_pos

  -- initialize guarding position, if hadn't one before, as the position
  -- this actor starts on
  if not guarding_pos then
    guarding_pos = { actor:getPos() }
    ai.guarding_pos = guarding_pos
  end

  -- if i don't have a target or it is dead, i'll look for one
  if not target or target:isDead() then
    target = FindTarget.getTarget(actor)
  end

  if target then
    -- if i have a target, can i see it?
    if actor:canSee(target) then
      -- if so, lock on to it
      target_pos = { target:getPos() }
    else
      -- if not, lose the target, but not its position
      target = false
    end
  elseif target_pos then
    -- if i don't have a target, but i have its last position...
    -- ...am i in the target's position?
    local i, j = actor:getPos()
    local k, l = unpack(target_pos)
    if i == k and l == j then
      -- if so, then i lost them completely
      target_pos = false
    end
  end

  -- update AI state
  ai.target = target
  ai.target_pos = target_pos

  -- if i have a position targeted
  if target_pos then
    -- ...if i have a target, then try to attack!
    if target then
      local plays = listCardPlays(actor, target, target_pos)
      local n = #plays
      while n > 0 do
        local i = RANDOM.generate(n)
        local play = plays[i]
        if MANEUVERS[_PLAY_CARD].validate(actor, play) then
          return _PLAY_CARD, play
        else
          table.remove(plays, i)
          n = n - 1
        end
      end
    end
    -- ...if i can't see or reach them, then at least chase it!
    local actor_pos = { actor:getPos() }
    local next_step = FindPath.getNextStep(actor_pos, target_pos, sector)
    local inputs = { pos = next_step }
    if next_step and MANEUVERS[_MOVE].validate(actor, inputs) then
      return _MOVE, inputs
    end
  end

  -- i don't have targets or any clue to my last target's position...
  -- ... time to return to guarding position if it isn't there yet
  target_pos = false
  ai.target_pos = target_pos
  local i, j = actor:getPos()
  local k, l = unpack(guarding_pos)
  if i ~= k or l ~= j then
    local actor_pos = { actor:getPos() }
    local next_step = FindPath.getNextStep(actor_pos, guarding_pos, sector, true)
    local inputs = { pos = next_step }
    if next_step and MANEUVERS[_MOVE].validate(actor, inputs) then
      return _MOVE, inputs
    end
  end
  -- if here, its back at the guarding position without threats in sight
  -- so it will idle
  return 'IDLE', {}
end
