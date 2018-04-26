
local DB = require 'database'
local RANDOM = require 'common.random'
local DEFS = require 'domain.definitions'
local BUILDER = {}

local function _card(specname)
  return {
    specname = specname,
    usages = 0,
  }
end

function BUILDER.build(background)
  local buffer = {}
  for _,cardinfo in ipairs(DB.loadSpec('actor', background).initial_buffer) do
    for i = 1, cardinfo.amount do
      table.insert(buffer, _card(cardinfo.card))
    end
  end
  RANDOM.shuffle(buffer)
  table.insert(buffer, DEFS.DONE)
  return buffer
end

return BUILDER

