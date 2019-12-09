
local Prototype = require 'lux.prototype' :new {}
local Graph = Prototype:new {}

-- Nodes are basically sector states
local function Node(id, zone, symb)
  local state = {}
  state.id = id
  state.zone = zone
  state.specname = symb
  state.exits = {}
  return state
end

local function NodeInfo(node) -- luacheck: no unused
  return string.format("%s(%s:%s)", node.id, node.zone, node.specname)
end

-- Create Graph
function Graph:create(idgenerator)
  local newgraph = self:new {}
  newgraph.idgen = idgenerator
  newgraph.nodes = {}
  newgraph.edges = {}
  return newgraph
end

-- Create Node in Graph
function Graph:addNode(zone, symb)
  local id = self.idgen.newID()
  local node = Node(id, zone, symb)
  self.nodes[id] = node
  return id
end

-- Remove Node from Graph
function Graph:removeNode(id)
  local node = self.nodes[id]
  for other_id in pairs(node.exits) do
    self:disconnect(id, other_id)
  end
  self.nodes[id] = nil
end

-- Connect Nodes in Graph
function Graph:connect(id1, id2)
  local nodes = self.nodes
  assert(nodes[id1] and nodes[id2], "Invalid node id.")
  nodes[id1].exits[id2] = {pos = false, target_pos = false, dir = 'down'}
  nodes[id2].exits[id1] = {pos = false, target_pos = false, dir = 'up'}
  --[[--
  printf("Connecting [%s] to [%s]",
         NodeInfo(self:getNode(id1)),
         NodeInfo(self:getNode(id2)))
  --]]--
end

-- Disconnect Nodes in Graph
function Graph:disconnect(id1, id2)
  local nodes = self.nodes
  assert(nodes[id1] and nodes[id2], "Invalid node id.")
  nodes[id1].exits[id2] = nil
  nodes[id2].exits[id1] = nil
  --[[--
  printf("Disconnecting [%s] to [%s]",
         NodeInfo(self:getNode(id1)),
         NodeInfo(self:getNode(id2)))
  --]]--
end

-- Get Node in Graph
function Graph:getNode(id)
  return self.nodes[id]
end

return Graph

