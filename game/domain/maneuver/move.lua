
local ACTIONDEFS = require 'domain.definitions.action'
local MOVE = {}

MOVE.param_specs = {
  { output = 'pos', typename = 'direction' },
}

function MOVE.activatedAbility(actor, params)
  return nil
end

function MOVE.validate(actor, params)
  local sector = actor:getBody():getSector()
  return sector:isValid(unpack(params.pos))
end

function MOVE.perform(actor, params)
  local sector = actor:getBody():getSector()
  actor:spendTime(ACTIONDEFS.MOVE_TIME)
  local pos = {actor:getPos()}
  sector:putBody(actor:getBody(), unpack(params.pos))
  coroutine.yield('report', {
    type = 'body_moved',
    body = actor:getBody(),
    origin = pos
  })
end

return MOVE

