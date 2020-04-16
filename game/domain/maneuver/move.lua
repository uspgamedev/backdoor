
local ACTIONDEFS  = require 'domain.definitions.action'
local MOVE = {}

MOVE.input_specs = {
  { output = 'pos', name = 'direction' },
}

function MOVE.card(_, _)
  return nil
end

function MOVE.activatedAbility(_, _)
  return nil
end

function MOVE.exhaustionCost(_, _)
  return ACTIONDEFS.FULL_EXHAUSTION
end

function MOVE.validate(actor, inputvalues)
  local sector = actor:getBody():getSector()
  return sector:isValid(unpack(inputvalues.pos))
end

function MOVE.perform(actor, inputvalues)
  local sector = actor:getBody():getSector()
  actor:exhaust(ACTIONDEFS.FULL_EXHAUSTION)
  local pos = {actor:getPos()}
  sector:putBody(actor:getBody(), unpack(inputvalues.pos))
  coroutine.yield('report', {
    type = 'body_moved',
    body = actor:getBody(),
    origin = pos,
    sfx = 'footstep',
    speed_factor = .5
  })
end

return MOVE

