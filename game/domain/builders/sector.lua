
local ACTOR_BUILDER = require 'domain.builders.actor'
local BODY_BUILDER = require 'domain.builders.body'
local DB = require 'database'
local DEFS = require 'domain.definitions'
local SCHEMATICS = require 'domain.definitions.schematics'
local TRANSFORMERS = require 'lux.pack' 'domain.transformers'

local BUILDER = {}

local _placeTiles
local _placeBodiesAndActors

function BUILDER.generateState(idgenerator, state)

  assert(not state.generated, "cannot build already generated sector state")

  -- initial generation information
  local info = {
    exits = state.exits
  }

  -- sector grid generation
  for _,transformer in DB.schemaFor('sector') do
    local spec = DB.loadSpec('sector', state.specname)[transformer.id]
    if spec and transformer.id ~= 'theme' then
      info = TRANSFORMERS[transformer.id].process(info, spec)
    end
  end

  _placeTiles(state, info.grid, info.drops)
  _placeBodiesAndActors(idgenerator, state, info.encounters)

  state.generated = true
  state.exits = info.exits

  return { state = state, player_pos = info.player_pos }
end

function _placeTiles(state, grid, drops)
  state.w, state.h = grid.getDim()
  state.tiles = {}
  for i = 1, state.h do
    state.tiles[i] = {}
    for j = 1, state.w do
      local tile = false
      local tile_type = grid.get(j, i)
      if tile_type and tile_type ~= SCHEMATICS.NAUGHT then
        tile = { type = tile_type, drops = {} }
        for _,drop in ipairs(drops[i][j]) do
          table.insert(tile.drops, drop)
        end
      end
      state.tiles[i][j] = tile
    end
  end
end

function _placeBodiesAndActors(idgenerator, state, encounters)
  state.bodies = {}
  state.actors = {}
  for _,encounter in ipairs(encounters) do
    local actor_specname, body_specname = unpack(encounter.monster)
    local i, j = unpack(encounter.pos)
    local body_state =
      BODY_BUILDER.buildState(idgenerator, body_specname, i, j)
    local actor_state =
      ACTOR_BUILDER.buildState(idgenerator, actor_specname, body_state)
    table.insert(state.bodies, body_state)
    table.insert(state.actors, actor_state)

    local zone_spec = DB.loadSpec('zone', state.zone)
    local difficulty_multiplier = 1 + zone_spec['difficulty']
    local upgradexp = encounter.upgrade_power

    upgradexp = math.floor(upgradexp * difficulty_multiplier)

    -- allocating exp
    if upgradexp > 0 then
      local total = 0
      local aptitudes = {}
      local actor_spec = DB.loadSpec('actor', actor_specname)
      for _,attr in ipairs(DEFS.PRIMARY_ATTRIBUTES) do
        aptitudes[attr] = actor_spec[attr:lower()] + 3 -- min of 1
        total = total + aptitudes[attr]
      end
      local unit = upgradexp / total
      for attr,priority in pairs(aptitudes) do
        local award = math.floor(unit * priority)
        if DEFS.PRIMARY_ATTRIBUTES[attr] then
          actor_state.upgrades[attr] = DEFS.ATTR.INITIAL_UPGRADE + award
        end
      end
    end
  end
end

return BUILDER

