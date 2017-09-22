
local DEFS = require 'domain.definitions'

local FX = {}

FX.schema = {
  { id = 'buffer', name = "Buffer Index", type = 'value', match = 'integer',
    range = {1,DEFS.ACTOR_BUFFER_NUM} }, 
  { id = 'card', name = "Card", type = 'value', match = 'card' }, 
}

function FX.process (actor, sector, params)
  actor:addCardToBackbuffer(params['card'], params['buffer'])
end

return FX

