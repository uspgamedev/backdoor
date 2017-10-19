
local DEFS        = require 'domain.definitions'
local SCHEMATICS  = require 'domain.definitions.schematics'
local COLORS      = require 'domain.definitions.colors'
local RANDOM      = require 'common.random'
local IDGenerator = require 'common.idgenerator'

local ROUTEBUILDER = {}

local function _card(specname)
  return {
    specname = specname,
    usages = 0,
  }
end

local function _simpleBuffer()
  local buffer = {}
  for i=1,4 do
    table.insert(buffer, _card('draw'))
    table.insert(buffer, _card('bolt'))
    table.insert(buffer, _card('cure'))
    table.insert(buffer, _card('sord'))
    table.insert(buffer, _card('gun'))
    table.insert(buffer, _card('ath_1'))
    table.insert(buffer, _card('arc_1'))
    table.insert(buffer, _card('mec_1'))
    table.insert(buffer, _card('def_1'))
    table.insert(buffer, _card('hp_5'))
  end
  RANDOM.shuffle(buffer)
  table.insert(buffer, DEFS.DONE)
  return buffer
end

local function _generatePlayerActorData(idgenerator, body_id, background)
  return {
    id = idgenerator.newID(),
    body_id = body_id,
    specname = background,
    cooldown = 10,
    exp = 0,
    playpoints = 10,
    equipped = {
      weapon = false,
      offhand = false,
      suit = false,
      tool = false,
      accessory = false,
    },
    widgets = {
      WIDGET_A = false,
      WIDGET_B = false,
      WIDGET_C = false,
      WIDGET_D = false,
    },
    upgrades = {ATH=0,ARC=0,MEC=0,SPD=0},
    buffer = _simpleBuffer(),
    hand_limit = 5,
    hand = {}
  }
end

local function _generatePlayerBodyData(idgenerator, species)
  return {
    id = idgenerator.newID(),
    specname = species,
    damage = 0,
    upgrades = {DEF=0,HP=0},
    i = 3,
    j = 5,
  }
end

local function _generateSectorsData(idgenerator, player_info)
  -- create first sector
  local sectors = {}
  local n = false
  local f = {type = SCHEMATICS.FLOOR}
  local e = {type = SCHEMATICS.EXIT}
  local first_sector = {
    specname = 'initial',
    id = idgenerator.newID(),
    tiles = {
      { n, n, n, n, n, n, n, },
      { n, n, n, n, n, n, n, },
      { n, n, f, f, f, n, n, },
      { n, n, f, e, f, n, n, },
      { n, n, f, f, f, n, n, },
      { n, n, n, n, n, n, n, },
      { n, n, n, n, n, n, n, },
    },
    w = 7,
    h = 7,
    depth = 0,
    bodies = {},
    actors = {},
    exits = {
      {
        pos = {4, 4},
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
