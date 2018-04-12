
local DB          = require 'database'
local DEFS        = require 'domain.definitions'
local SCHEMATICS  = require 'domain.definitions.schematics'
local COLORS      = require 'domain.definitions.colors'
local BUILDDATA   = require 'domain.definitions.routebuilddata'
local RANDOM      = require 'common.random'
local IDGenerator = require 'common.idgenerator'


local ROUTEBUILDER = {}

local function _card(specname)
  return {
    specname = specname,
    usages = 0,
  }
end

local function _simpleBuffer(background)
  local buffer = {}
  for _,cardinfo in ipairs(DB.loadSpec('actor', background).initial_buffer) do
    for i=1, cardinfo.amount do
      table.insert(buffer, _card(cardinfo.card))
    end
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
    playpoints = DEFS.MAX_PP,
    upgrades = {COR=100,ARC=100,ANI=100,SPD=100},
    buffer = _simpleBuffer(background),
    hand_limit = 5,
    hand = {},
    prizes = {},
  }
end

local function _generatePlayerBodyData(idgenerator, species, pos)
  local i, j = unpack(pos)
  return {
    id = idgenerator.newID(),
    specname = species,
    damage = 0,
    upgrades = {DEF=100,VIT=100},
    i = i,
    j = j,
    equipped = {
      weapon = false,
      offhand = false,
      suit = false,
      tool = false,
      accessory = false,
    },
    widgets = {},
  }
end

local function _generateInitialSectorTiles()
  local tiles = {}
  local base = BUILDDATA.initial_sector_tiles
  local mw = 9
  local mh = 7
  local width = mw*2
  local height = mh*2

  -- get width and height
  local valid_tiles = {}
  for line in base:gmatch("(.-)\n") do
    -- set valid tiles grid
    table.insert(valid_tiles, {})
    local current_line = #valid_tiles
    local line_length = line:len()
    for j = 1, line_length do
      valid_tiles[current_line][j] = line:sub(j, j)
    end
    -- set width and height
    width = math.max(width, mw*2 + line_length)
    height = height + 1
  end

  -- tiles
  local f = function() return {type = SCHEMATICS.FLOOR, drops = {}} end
  local g = function() return {type = SCHEMATICS.EXIT, drops = {}} end
  local n = false

  tiledata = {}
  for i = 1, height do
    tiles[i] = {}
    for j = 1, width do
      tiles[i][j] = n
      if i > mh and j > mw and i <= height - mh and j <= width - mw then
        local ti, tj = i - mh, j - mw
        local valid_tile = valid_tiles[ti][tj]
        if valid_tile == 'e' then
          tiledata.initial_pos = {i, j}
          tiles[i][j] = f()
        elseif valid_tile == '.' then
          tiles[i][j] = f()
        elseif valid_tile == '>' then
          tiledata.exit_pos = {i, j}
          tiles[i][j] = g()
        end
      end
    end
  end
  tiledata.width = width
  tiledata.height = height
  tiledata.tiles = tiles

  return tiledata
end

local function _generateSectorsData(idgenerator, player_info)
  -- create first sector
  local sectors = {}
  local n = false
  local f = function() return {type = SCHEMATICS.FLOOR, drops = {}} end
  local e = function() return {type = SCHEMATICS.EXIT, drops = {}} end

  local tiledata = _generateInitialSectorTiles()

  local first_sector = {
    specname = 'initial',
    id = idgenerator.newID(),
    tiles = tiledata.tiles,
    w = tiledata.width,
    h = tiledata.height,
    depth = 0,
    bodies = {},
    actors = {},
    exits = {
      {
        pos = tiledata.exit_pos,
        target_specname = "sector01",
      },
    }
  }

  -- generate player
  local player_body = _generatePlayerBodyData(idgenerator,
                                              player_info.species,
                                              tiledata.initial_pos)
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
  local route_name_idx = RANDOM.safeGenerate(#BUILDDATA.route_names)
  data.version = VERSION
  data.id = route_id
  data.rng_seed = RANDOM.getSeed()
  data.rng_state = RANDOM.getState()
  data.sectors = _generateSectorsData(idgenerator, player_info)
  data.next_id = idgenerator.getNextID()
  data.current_sector_id = data.sectors[1].id
  data.player_name = BUILDDATA.route_names[route_name_idx]
  data.player_id = data.sectors[1].actors[1].id
  data.behaviors = { ai = {} }
  return data
end

function ROUTEBUILDER.build(route_id, player_info)
  return _generateRouteData(route_id, player_info)
end

return ROUTEBUILDER
