
local DB = require 'database'
local RANDOM = require 'common.random'
local CARDSET = require 'domain.cardset'

local COLLECTION = {}

function COLLECTION.generatePackFrom(collection_name)
  local collection = DB.loadSpec('collection', collection_name)
  local pack = {}
  local n = 0
  for _,card_drop in pairs(collection.cards) do
    local p = RANDOM.generate(1, 100)
    if p <= card_drop.drop then
      n = n + 1
      pack[n] = CARDSET.getRandomCardFrom(card_drop.set)
    end
  end
  return pack
end

return COLLECTION

