
local DEFS = require 'domain.definitions'

local FX = {}

FX.schema = {
  { id = 'card', name = "Card", type = 'value', match = 'card' }, 
}

function FX.process (actor, fieldvalues)
  actor:addCardToBackbuffer(fieldvalues['card'])
end

return FX

