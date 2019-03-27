
local DB = require 'database'
local Graph = require 'common.graph'
local ROUTEMAPDEFS = require 'domain.definitions.routemap'
local BODY_BUILDER = require 'domain.builders.body'
local ACTOR_BUILDER = require 'domain.builders.actor'

local BUILDER = {}

function BUILDER.build(idgenerator, player_data)
  local route_map = Graph:create(idgenerator)
  local sectors = {}

  -- create nodes
  for i, node_info in ipairs(ROUTEMAPDEFS.initial_nodes) do
    local id = route_map:addNode(unpack(node_info))
    sectors[i] = route_map:getNode(id)
  end

  -- connect nodes
  for i, connection_info in ipairs(ROUTEMAPDEFS.initial_connections) do
    local idx, jdx = unpack(connection_info)
    local id1 = sectors[idx].id
    local id2 = sectors[jdx].id
    route_map:connect(id1, id2)
  end

  -- generate player
  local species = player_data.species
  local background = player_data.background
  local pbody = BODY_BUILDER.buildState(idgenerator, species, 16, 12)
  local pactor = ACTOR_BUILDER.buildState(idgenerator, background, pbody)

  -- generate npcs

  local npcs = {
    BODY_BUILDER.buildState(idgenerator, "corgi", 11, 11),
    BODY_BUILDER.buildState(idgenerator, "slime", 9, 13),
  }
  npcs[1].dialogue = "[pause=1][speed=ultrafast][style=shake][font=big]HELO[pause=1][font=regular][style=none] mi frend... How are you?[color=red] I, for once, [color=blue]am [style=wave]totally[style=none] fine. [font=small][color=red][speed=medium][opacity=semi]        bye"
  npcs[2].dialogue = "howdy"


  -- generate first sector
  local tiledata = DB.loadSetting('init_tiledata')
  local first_sector
  for _,sector in ipairs(sectors) do
    if sector.specname == "initial" then
      first_sector = sector
      break
    end
  end

  assert(first_sector, "No first sector???")

  first_sector.tiles = tiledata.tiles
  first_sector.h = #tiledata.tiles
  first_sector.w = #tiledata.tiles[1]
  first_sector.bodies = { pbody }
  for _, body in ipairs(npcs) do
    table.insert(first_sector.bodies, body)
  end
  first_sector.actors = { pactor }
  first_sector.generated = true
  local _,exit = next(first_sector.exits)
  exit.pos = tiledata.exit

  return sectors, first_sector
end

return BUILDER
