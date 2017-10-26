
local DEFS = require 'domain.definitions'
local MOD = require 'domain.modifier'

local FX = {}

FX.schema = {
  { id = 'card', name = "Card", type = 'value', match = 'card' },
}

function FX.process (actor, sector, params)
  local card = params['card']
  local attr = card:getRelatedAttr()
  MOD.new(actor, attr, 'add', 1, DEFS.TIME_UNIT)
end

return FX

