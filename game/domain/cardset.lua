
local DB = require 'database'
local RANDOM = require 'common.random'
local Card = require 'domain.card'

local CARDSET = {}

local function _getParent(setname)
  return DB.loadSpec('cardset', setname).parent
end

local function _belongs(setname, from)
  if not setname then return false end
  if setname == from then return true end
  local parentset = _getParent(setname)
  return _belongs(parentset, from)
end

local function _getCardsFrom(setname)
  local cardlist = {}
  local n = 0
  for cardname in DB.listDomainItems("card") do
    if _belongs(DB.loadSpec('card', cardname).set, setname) then
      n = n + 1
      cardlist[n] = cardname
    end
  end
  return cardlist
end

function CARDSET.getRandomCardFrom(setname)
  local cardlist = _getCardsFrom(setname)
  local parent = _getParent(setname)
  if parent and RANDOM.generate(1, 10) == 1 then
    return CARDSET.getRandomCardFrom(parent)
  end
  return Card(cardlist[RANDOM.generate(1, #cardlist)])
end

return CARDSET

