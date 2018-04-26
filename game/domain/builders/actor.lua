
local BUFFER_BUILDER = require 'domain.buffer'

local BUILDER = {}

function BUILDER.build(idgenerator, body_id, background)
  return {
    id = idgenerator.newID(),
    body_id = body_id,
    specname = background,
    cooldown = 10,
    exp = 0,
    playpoints = DEFS.MAX_PP,
    upgrades = {
      COR = 100,
      ARC = 100,
      ANI = 100,
      SPD = 100,
    },
    buffer = BUFFER_BUILDER.build(background),
    hand_limit = 5,
    hand = {},
    prizes = {},
  }
end

return BUILDER

