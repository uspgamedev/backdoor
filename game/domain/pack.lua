
local RNG   = require 'common.random'
local DB    = require 'database'
local DEFS  = require 'domain.definitions'

local PACK = {}

function PACK.open(collection_name)
  local cards = DB.loadSpec('collection', collection_name).cards
  local pack = {}
  local total = #cards
  for i=1,DEFS.PACK_SIZE do
    table.insert(pack, cards[RNG.generate(total)].card)
  end
  return pack
end

return PACK

