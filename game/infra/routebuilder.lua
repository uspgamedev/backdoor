
local DEFS        = require 'domain.definitions'
local SCHEMATICS  = require 'domain.definitions.schematics'
local COLORS      = require 'domain.definitions.colors'
local RANDOM      = require 'common.random'
local IDGenerator = require 'common.idgenerator'

local ROUTEBUILDER = {}

local function _simpleBuffer()
  local buffer = {}
  for i=1,4 do
    table.insert(buffer, 'bolt')
    table.insert(buffer, 'cure')
    table.insert(buffer, 'draw')
    table.insert(buffer, 'ath +1')
    table.insert(buffer, 'arc +1')
    table.insert(buffer, 'mec +1')
  end
  RANDOM.shuffle(buffer)
  table.insert(buffer, DEFS.DONE)
  return buffer
end

local function _generatePlayerActorData(idgenerator, body_id, background)
  -- FIXME: ALL PLAYER BACKGROUNDS HAVE THE SAME ACTIONS
  -- suggestion: have the primary action be registered in the DB
  return {
    id = idgenerator.newID(),
    body_id = body_id,
    specname = background,
    cooldown = 10,
    exp = 0,
    upgrades = {ATH=0,ARC=0,MEC=0},
    actions = {
      PRIMARY = "DOUBLESHOOT",
      WIDGET_A = "HEAL",
    },
    buffers = {
      _simpleBuffer(),
      _simpleBuffer(),
      _simpleBuffer(),
    },
    hand_limit = 5,
    hand = {}
  }
end

local function _generatePlayerBodyData(idgenerator, species)
  return {
    id = idgenerator.newID(),
    specname = species,
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
    depth = 0,
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
  local player_body = _generatePlayerBodyData(idgenerator, player_info.species)
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
