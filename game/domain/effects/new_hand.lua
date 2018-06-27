
local DEFS = require 'domain.definitions'

local FX = {}

FX.schema = {
  { id='nothing', type='none', name = "NO PARAM" }
}

function FX.process (actor, fieldvalues)
  if actor:isHandEmpty() then
    for i = 1, DEFS.HAND_LIMIT do
      actor:drawCard()
    end
  end
end

return FX

