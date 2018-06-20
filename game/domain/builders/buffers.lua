
local DB = require 'database'
local RANDOM = require 'common.random'
local DEFS = require 'domain.definitions'

local CARD_BUILDER = require 'domain.builders.card'

local BUILDER = {}

function BUILDER.build(idgenerator, background)
  local buffer = {}
  for _,cardinfo in ipairs(DB.loadSpec('actor', background).initial_buffer) do
    for i = 1, cardinfo.amount do
      table.insert(buffer, CARD_BUILDER.buildState(idgenerator, cardinfo.card))
    end
  end
  RANDOM.shuffle(buffer)
  table.insert(buffer, DEFS.DONE)
  return buffer
end

return BUILDER

