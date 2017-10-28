
local DEFS = require 'domain.definitions'

local maneuver = {}

maneuver.schema = {}

function maneuver.validate(actor, sector, params)
  return actor:isHandEmpty() and actor:getPP() >= DEFS.NEW_HAND_COST
end

function maneuver.perform(actor, sector, params)
  actor:spendPP(DEFS.NEW_HAND_COST)
  for i = 1, DEFS.HAND_LIMIT do
    actor:drawCard()
  end
end

return maneuver

