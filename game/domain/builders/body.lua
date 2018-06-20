
local Body require 'domain.body'

local BUILDER = {}

function BUILDER.build(idgenerator, species, i, j, is_state)
  local state = {
      id = idgenerator.newID(),
      specname = species,
      damage = 0,
      upgrades = {
        DEF = 100,
        VIT = 100,
      },
      i = i,
      j = j,
      equipped = {
        weapon = false,
        offhand = false,
        suit = false,
        tool = false,
        accessory = false,
      },
      widgets = {},
    }
  if is_state then
    return state
  else
    local body = Body(species)
    body:loadState(state)
    return body
  end
end

return BUILDER

