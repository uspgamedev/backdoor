
local BUILDER = {}

function BUILDER.build(idgenerator, species, i, j)
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

return BUILDER

