
local MANEUVERS  = require 'lux.pack' 'domain.maneuver'
local ACTIONDEFS = require 'domain.definitions.action'
local RANDOM     = require 'common.random'
local DIR        = require 'domain.definitions.dir'

local _IDLE = 0

local RandomWalk = {}

function RandomWalk.execute(actor)
  local i, j = actor:getPos()
  local input = {}
  repeat
    local idx = RANDOM.generate(0, 4)
    if idx == 0 then
      return ACTIONDEFS.IDLE, {}
    end
    local di, dj = unpack(DIR[DIR[idx]])
    input.pos = {i+di, j+dj}
  until MANEUVERS[ACTIONDEFS.MOVE].validate(actor, input)
  return ACTIONDEFS.MOVE, input
end

return RandomWalk
