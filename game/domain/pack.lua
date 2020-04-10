
local DB = require 'database'
local RANDOM = require 'common.random'
local CARDSET = require 'domain.cardset'
local DEFS    = require 'domain.definitions'

local _EMPTY = {}

local PACK = {}

function PACK.generatePackFrom(collection_name)
  if not collection_name then return _EMPTY end
  local collection = DB.loadSpec('collection', collection_name)
  local pack = {}
  local n = 0
  while n < DEFS.PACK_SIZE do
    for _,card_drop in pairs(collection.cards) do
      local p = RANDOM.generate(1, 100)
      if p <= card_drop.drop then
        n = n + 1
        pack[n] = CARDSET.getRandomCardFrom(card_drop.set)
      end
      if n >= DEFS.PACK_SIZE then break end
    end
  end
  return pack
end

return PACK

