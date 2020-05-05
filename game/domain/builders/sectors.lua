
local Graph = require 'common.graph'
local ROUTEMAPDEFS = require 'domain.definitions.routemap'
local BODY_BUILDER = require 'domain.builders.body'
local ACTOR_BUILDER = require 'domain.builders.actor'
local SECTOR_BUILDER = require 'domain.builders.sector'

local BUILDER = {}

function BUILDER.build(idgenerator, player_data)
  local route_map = Graph:create(idgenerator)
  local sectors = {}

  BUILDER._createNodes(route_map, sectors)
  BUILDER._connectNodes(route_map, sectors)

  local first_sector = BUILDER._findFirstSector(sectors)

  assert(first_sector, "No first sector???")

  local info = SECTOR_BUILDER.generateState(idgenerator, first_sector)

  -- generate player
  BUILDER._insertPlayer(first_sector, player_data, info.player_pos, idgenerator)

  return sectors, first_sector
end

function BUILDER._createNodes(route_map, sectors)
  for i, node_info in ipairs(ROUTEMAPDEFS.initial_nodes) do
    local id = route_map:addNode(unpack(node_info))
    sectors[i] = route_map:getNode(id)
  end
end

function BUILDER._connectNodes(route_map, sectors)
  for _, connection_info in ipairs(ROUTEMAPDEFS.initial_connections) do
    local idx, jdx = unpack(connection_info)
    local id1 = sectors[idx].id
    local id2 = sectors[jdx].id
    route_map:connect(id1, id2)
  end
end

function BUILDER._findFirstSector(sectors)
  for _,sector in ipairs(sectors) do
    if sector.specname == "tutorial" then
      return sector
    end
  end
end

function BUILDER._insertPlayer(sector, player_data, pos, idgenerator)
  local species = player_data.species
  local background = player_data.background
  local pbody = BODY_BUILDER.buildState(idgenerator, species, unpack(pos))
  local pactor = ACTOR_BUILDER.buildState(idgenerator, background, pbody)

  -- Place player
  table.insert(sector.bodies, pbody)
  table.insert(sector.actors, pactor)
end

return BUILDER

