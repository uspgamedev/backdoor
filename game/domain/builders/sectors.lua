
local Graph = require 'common.graph'
local ROUTEMAPDEFS = require 'domain.definitions.routemap'
local BODY_BUILDER = require 'domain.builders.body'
local ACTOR_BUILDER = require 'domain.builders.actor'
local SECTOR_BUILDER = require 'domain.builders.sector'

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
  for _, connection_info in ipairs(ROUTEMAPDEFS.initial_connections) do
    local idx, jdx = unpack(connection_info)
    local id1 = sectors[idx].id
    local id2 = sectors[jdx].id
    route_map:connect(id1, id2)
  end

  -- generate player
  local species = player_data.species
  local background = player_data.background
  local pbody = BODY_BUILDER.buildState(idgenerator, species, 11, 11)
  local pactor = ACTOR_BUILDER.buildState(idgenerator, background, pbody)

  -- generate npcs

  --local npcs = {
  --  BODY_BUILDER.buildState(idgenerator, "corgi", 11, 11),
  --  BODY_BUILDER.buildState(idgenerator, "slime", 9, 13),
  --}
  --npcs[1].dialogue = "Welcome to pre-alpha backdoor!"

  --npcs[2].dialogue = "Find [color value:red]Vanth's fruit[color value:regular] to win the game."


  -- generate first sector
  local first_sector
  for _,sector in ipairs(sectors) do
    if sector.specname == "initial" then
      first_sector = sector
      break
    end
  end

  assert(first_sector, "No first sector???")

  SECTOR_BUILDER.generateState(idgenerator, first_sector)

  -- Place player
  table.insert(first_sector.bodies, pbody)
  table.insert(first_sector.actors, pactor)

  return sectors, first_sector
end

return BUILDER
