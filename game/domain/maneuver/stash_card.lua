
local ACTIONDEFS  = require 'domain.definitions.action'
local STASH       = {}

STASH.param_specs = {
  { output = 'card_index', typename = 'card_index' }
}

local function _card(actor, params)
  return actor:getCard(params.card_index)
end

function STASH.activatedAbility(actor, sector, params)
  return nil
end

function STASH.validate(actor, sector, params)
  return not not _card(actor, params)
end

function STASH.perform(actor, sector, params)
  actor:addCardToBackbuffer(actor:removeHandCard(params.card_index))
  --FIXME: BUFF ACTOR!
end

return STASH

