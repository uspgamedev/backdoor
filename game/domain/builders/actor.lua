
local DB             = require 'database'
local CARD_BUILDER   = require 'domain.builders.card'
local BUFFER_BUILDER = require 'domain.builders.buffers'
local DEFS           = require 'domain.definitions'
local Actor          = require 'domain.actor'

local BUILDER = {}

function BUILDER.buildState(idgenerator, background, body_state)
  -- WARNING: Do not instantiate body before building the actor!
  -- Build only bodystate instead. If not possible (body already exists),
  -- you will have to reload its state after calling this function. If so,
  -- do not lose the 'body_state' reference, as it is edited in-place here.
  local traits_specs = DB.loadSpec('actor', background)['traits']
  local id = idgenerator.newID()
  if traits_specs then
    for _,trait_spec in ipairs(traits_specs) do
      local trait = CARD_BUILDER.buildState(idgenerator, trait_spec.specname,
                                            id)
      table.insert(body_state.widgets, trait)
    end
  end
  return {
    id = id,
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
    buffer = BUFFER_BUILDER.build(idgenerator, background),
    hand_limit = 5,
    hand = {},
    prizes = {},
  }
end

function BUILDER.buildElement(idgenerator, background, body_state)
  local state = BUILDER.buildState(idgenerator, background, body_state)
  local actor = Actor(background)
  actor:loadState(state)
  return actor
end

return BUILDER

