
local DEFS = require 'domain.definitions'
local FX = {}

FX.schema = {}

function FX.process (actor, sector, params)
  actor:spendPP(DEFS.NEW_HAND_COST)
end

return FX

