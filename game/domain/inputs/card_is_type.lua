
local DEFS = require 'domain.definitions'
local INPUT = {}

INPUT.schema = {
  { id = 'card', name = "Card", type = 'value', match = 'card' },
  { id = 'cardtype', name = "Type", type = 'enum',
    options = DEFS.CARD_TYPES },
  { id = 'output', name = "Label", type = 'output' }
}

INPUT.type = 'boolean'

function INPUT.isValid(actor, fieldvalues, value)
  local cardtype  = fieldvalues['cardtype']
  local card      = fieldvalues['card']
  if cardtype == 'ART' then
    return card:isArt()
  elseif cardtype == 'WIDGET' then
    return card:isWidget()
  end
  return false
end

return INPUT

