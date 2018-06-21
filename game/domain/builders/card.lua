
local Card = require 'domain.card'

local BUILDER = {}

function BUILDER.buildState(specname)
  return {
    specname = specname,
    usages = 0,
  }
end

function BUILDER.buildElement(specname)
  local state = BUILDER.buildState(specname)
  local card = Card(specname)
  card:loadState(state)
  return card
end

return BUILDER

