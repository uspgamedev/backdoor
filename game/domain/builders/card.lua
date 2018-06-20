
local Card = require 'domain.card'

local BUILDER = {}

function BUILDER.build(specname, is_state)
  local state = {
    specname = specname,
    usages = 0,
  }
  if is_state then
    return state
  else
    local card = Card(specname)
    card:loadState(state)
    return card
  end
end

return BUILDER

