
local DB = require 'database'
local CARD_BUILDER   = require 'domain.builders.card'
local BUFFER_BUILDER = require 'domain.builders.buffers'
local DEFS           = require 'domain.definitions'
local Actor          = require 'domain.actor'

local BUILDER = {}

function BUILDER.build(idgenerator, background, body_state, is_state)
  local traits_specs = DB.loadSpec('actor', background)['traits']
  if traits_specs then
    for _,trait_spec in ipairs(traits_specs) do
      local trait = CARD_BUILDER.build(trait_spec.specname, true)
      table.insert(body_state.widgets, trait)
    end
  end
  local state = {
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
  if is_state then
    return state
  else
    local actor = Actor(background)
    actor:loadState(state)
    return actor
  end
end

return BUILDER

