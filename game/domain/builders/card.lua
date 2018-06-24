
local Card = require 'domain.card'

local BUILDER = {}

function BUILDER.buildState(idgenerator, specname, owner_id)
  return {
    id = idgenerator.newID(),
    owner_id = owner_id,
    specname = specname,
    usages = 0,
  }
end

function BUILDER.buildElement(idgenerator, specname, owner_id)
  local state = BUILDER.buildState(idgenerator, specname, owner_id)
  local card = Card(specname)
  card:loadState(state)
  return card
end

return BUILDER

