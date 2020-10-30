
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
  local total_weight = 0
  for _,card_drop in pairs(collection.cards) do
    total_weight = total_weight + card_drop.drop
  end
  local n = 0
  while n < DEFS.PACK_SIZE do
    local p = RANDOM.generate(0, total_weight)
    local cur_weight = 0
    for _,card_drop in pairs(collection.cards) do
      cur_weight = cur_weight + card_drop.drop
      if p <= cur_weight then
        n = n + 1
        pack[n] = CARDSET.getRandomCardFrom(card_drop.set)
        break
      end
    end
  end
  return pack
end

return PACK
