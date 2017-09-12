
local SCHEMATICS = require 'domain.definitions.schematics'
local COLORS = require 'domain.definitions.colors'
local RANDOM = require 'common.random'
local IDGenerator = require 'common.idgenerator'

local ROUTEBUILDER = {}

local function _generatePlayerActorData(idgenerator, body_id, background)
  -- FIXME: ALL PLAYER BACKGROUNDS HAVE THE SAME ACTIONS
  -- suggestion: have the primary action be registered in the DB
  return {
    id = idgenerator.newID(),
    body_id = body_id,
    specname = background,
    cooldown = 10,
    actions = {
      PRIMARY = "DOUBLESHOOT",
      WIDGET_A = "HEAL",
    },
    hand_limit = 5,
    hand = {}
  }
end

local function _generatePlayerBodyData(idgenerator, race)
  return {
    id = idgenerator.newID(),
    specname = race,
    damage = 0,
    i = 1,
    j = 3,
  }
end

local function _generateSectorsData(idgenerator, player_info)
  -- create first sector
  local sectors = {}
  local t = {
    type = SCHEMATICS.FLOOR,
    unpack(COLORS.FLOOR1)
  }
  local r = {
    type = SCHEMATICS.FLOOR,
    unpack(COLORS.FLOOR2)
  }
  local e = {
    type = SCHEMATICS.EXIT,
    unpack(COLORS.EXIT)
  }
  local first_sector = {
    specname = 'initial',
    id = idgenerator.newID(),
    tiles = {
      { t, r, t, },
      { r, e, r, },
      { t, r, t, },
    },
    w = 3,
    h = 3,
    bodies = {},
    actors = {},
    exits = {
      {
        pos = {2, 2},
        target_specname = "sector01",
      },
    }
  }

  -- generate player
  local player_body = _generatePlayerBodyData(idgenerator, player_info.race)
  local player_actor = _generatePlayerActorData(idgenerator,
                                                player_body.id,
                                                player_info.background)

  -- populate first sector
  first_sector.bodies[1] = player_body
  first_sector.actors[1] = player_actor

  sectors[1] = first_sector

  -- create player
  return sectors
end

local function _generateRouteData(route_id, player_info)
  RANDOM.setSeed(RANDOM.generateSeed())
  local idgenerator = IDGenerator()
  local data = {}
  data.version = VERSION
  data.id = route_id
  data.rng_seed = RANDOM.getSeed()
  data.rng_state = RANDOM.getState()
  data.sectors = _generateSectorsData(idgenerator, player_info)
  data.next_id = idgenerator.getNextID()
  data.current_sector_id = data.sectors[1].id
  data.player_name = "Banana"
  data.player_id = data.sectors[1].actors[1].id
  return data
end

function ROUTEBUILDER.build(route_id, player_info)
  return _generateRouteData(route_id, player_info)
end

return ROUTEBUILDER
