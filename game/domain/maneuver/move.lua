
local ACTIONDEFS = require 'domain.definitions.action'
local MOVE = {}

MOVE.param_specs = {
  { output = 'pos', typename = 'direction' },
}

function MOVE.activatedAbility(actor, sector, params)
  return nil
end

function MOVE.validate(actor, sector, params)
  return sector:isValid(unpack(params.pos))
end

function MOVE.perform(actor, sector, params)
  actor:spendTime(ACTIONDEFS.MOVE_COST)
  local pos = {actor:getPos()}
  sector:putBody(actor:getBody(), unpack(params.pos))
  coroutine.yield('report', {
    type = 'body_moved',
    body = actor:getBody(),
    origin = pos
  })
end

return MOVE

