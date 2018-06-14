
local DB = require 'database'
local BUFFER_BUILDER = require 'domain.builders.buffers'
local DEFS           = require 'domain.definitions'
local Card           = require 'domain.card'

local BUILDER = {}

function BUILDER.build(idgenerator, background, body_state)
  local signature = Card(DB.loadSpec('actor', background)['signature'])
  table.insert(body_state.widgets, signature:saveState())
  return {
    id = idgenerator.newID(),
    body_id = body_state.id,
    specname = background,
    cooldown = 10,
    exp = 0,
    playpoints = DEFS.MAX_PP,
    upgrades = {
      COR = 100,
      ARC = 100,
      ANI = 100,
    },
    buffer = BUFFER_BUILDER.build(background),
    hand_limit = 5,
    hand = {},
    prizes = {},
  }
end

return BUILDER

