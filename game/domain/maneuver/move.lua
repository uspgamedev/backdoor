
local ACTIONDEFS  = require 'domain.definitions.action'
local ABILITY     = require 'domain.ability'
local DB          = require 'database'
local MOVE = {}

MOVE.input_specs = {
  { output = 'pos', name = 'direction' },
}

function MOVE.activatedAbility(actor, inputvalues)
  return nil
end

function MOVE.validate(actor, inputvalues)
  local sector = actor:getBody():getSector()
  return sector:isValid(unpack(inputvalues.pos))
end

function MOVE.perform(actor, inputvalues)
  local sector = actor:getBody():getSector()
  actor:exhaust(ACTIONDEFS.MOVE_COST)
  local pos = {actor:getPos()}
  sector:putBody(actor:getBody(), unpack(inputvalues.pos))
  coroutine.yield('report', {
    type = 'body_moved',
    body = actor:getBody(),
    origin = pos,
    sfx = 'footstep',
    speed_factor = 1.0
  })
end

return MOVE

