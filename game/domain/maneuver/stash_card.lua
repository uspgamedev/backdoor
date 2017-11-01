
local ACTIONDEFS  = require 'domain.definitions.action'
local STASH_CARDS = require 'domain.definitions.stash_cards'
local Card        = require 'domain.card'
local STASH       = {}

STASH.param_specs = {
  { output = 'card_index', typename = 'card_index' }
}

local function _card(actor, params)
  return actor:getHandCard(params.card_index)
end

function STASH.activatedAbility(actor, sector, params)
  return nil
end

function STASH.validate(actor, sector, params)
  return not not _card(actor, params)
end

function STASH.perform(actor, sector, params)
  local card = actor:removeHandCard(params.card_index)
  actor:addCardToBackbuffer(card)
  local stash_bonus = Card(STASH_CARDS[card:getRelatedAttr()])
  actor:getBody():placeWidget(stash_bonus)
end

return STASH

