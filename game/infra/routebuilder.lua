
local SCHEMATICS = require 'definitions.schematics'
local RANDOM = require 'common.random'
local IDGenerator = require 'common.idgenerator'

local ROUTEBUILDER = {}

local function _generatePlayerActorData(idgenerator, body_id)
  return {
    id = idgenerator.newID(),
    body_id = body_id,
    specname = "player",
    cooldown = 10,
    actions = {
      IDLE = true,
      MOVE = true,
      PRIMARY = "DRAW"
    },
    hand_limit = 7,
    hand = {}
  }
end

local function _generatePlayerBodyData(idgenerator)
  return {
    id = idgenerator.newID(),
    specname = "hearthborn",
    damage = 0,
    i = 1,
    j = 3,
  }
end

local function _generateSectorsData(idgenerator)
  -- create first sector
  local sectors = {}
  local t = SCHEMATICS.FLOOR
  local first_sector = {
    specname = 'initial',
    id = idgenerator.newID(),
    tiles = {
      { t, t, t, },
      { t, t, t, },
      { t, t, t, },
    },
    w = 3,
    h = 3,
    bodies = {},
    actors = {},
  }

  -- generate player
  local player_body = _generatePlayerBodyData(idgenerator)
  local player_actor = _generatePlayerActorData(idgenerator, player_body.id)

  -- populate first sector
  first_sector.bodies[1] = player_body
  first_sector.actors[1] = player_actor

  sectors[1] = first_sector
  for i = 2, 4 do
    local sector = { specname = 'sector01' }
    sectors[i] = sector
  end

  -- create player
  return sectors
end

local function _generateRouteData(route_id)
  RANDOM.setSeed(RANDOM.generateSeed())
  local idgenerator = IDGenerator()
  local data = {}
  data.version = VERSION
  data.id = route_id
  data.rng_seed = RANDOM.getSeed()
  data.rng_state = RANDOM.getState()
  data.sectors = _generateSectorsData(idgenerator)
  data.next_id = idgenerator.getNextID()
  data.current_sector_id = data.sectors[1].id
  data.player_name = "Banana"
  data.player_id = data.sectors[1].actors[1].id
  return data
end

function ROUTEBUILDER.build(route_id)
  return _generateRouteData(route_id)
end

return ROUTEBUILDER
