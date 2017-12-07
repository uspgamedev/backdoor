
local DEFS = require 'domain.definitions'
local PARAM = {}

PARAM.schema = {
  { id = 'card', name = "Card", type = 'value', match = 'card' },
  { id = 'type', name = "Type", type = 'enum',
    options = DEFS.CARD_TYPES },
  { id = 'output', name = "Label", type = 'output' }
}

PARAM.type = 'boolean'

function PARAM.isValid(actor, parameter, value)
  local cardtype  = parameter['type']
  local card      = parameter['card']
  if cardtype == 'ART' then
    return card:isArt()
  elseif cardtype == 'WIDGET' then
    return card:isWidget()
  elseif cardtype == 'UPGRADE' then
    return card:isUpgrade()
  end
  return false
end

return PARAM

