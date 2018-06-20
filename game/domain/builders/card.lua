
local Card = require 'domain.card'

local BUILDER = {}

function BUILDER.buildState(idgenerator, specname)
  return {
    id = idgenerator.newID(),
    specname = specname,
    usages = 0,
  }
end

function BUILDER.buildElement(idgenerator, specname)
  local state = BUILDER.buildState(idgenerator, specname)
  local card = Card(specname)
  card:loadState(state)
  return card
end

return BUILDER

