
local Body require 'domain.body'

local BUILDER = {}

function BUILDER.buildState(idgenerator, species, i, j)
  return {
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
end

function BUILDER.buildElement(idgenerator, species, i, j)
  local state = BUILDER.buildState(idgenerator, species, i, j)
  local body = Body(species)
  body:loadState(state)
  return body
end

return BUILDER

