
local function Node(zone, symb)
  return ("%s:%s"):format(zone, symb)
end

local Graph = require 'lux.class' :new()

function Graph:instance(obj)
  local _edges = {}
  local _nodes = {}
  local _size = 0

  function obj.addNode(zone, symb)
    local node = Node(zone, symb)
    local idx = _size + 1
    _size = idx
    _nodes[idx] = node
    _edges[idx] = {}
    for j = 1, _size do
      _edges[j][idx] = false
      _edges[idx][j] = false
    end
    return idx
  end

  function obj.removeNode(idx)
    for j = 1, _size do
      _edges[idx][j] = false
      _edges[j][idx] = false
    end
  end

  function obj.connect(idx1, idx2)
    assert(idx1 <= _size and idx2 <= _size)
    _edges[idx1][idx2] = true
    _edges[idx2][idx1] = true
  end

  function obj.disconnect(idx1, idx2)
    assert(idx1 <= _size and idx2 <= _size)
    _edges[idx1][idx2] = false
    _edges[idx2][idx1] = false
  end

  function obj.clone()
    local clone = Graph()
    for idx in ipairs(_nodes) do
      local zone, symb = obj.getNodeInfo(idx)
      clone.addNode(zone, symb)
    end
    for i = 1, _size do
      for j = 1, _size do
        if _edges[i][j] then
          clone.connect(i, j)
        end
      end
    end
    return clone
  end

  function obj.eachNode()
    return ipairs(_nodes)
  end

  function obj.getConnections(idx)
    local connections = {}
    for j = 1, _size do
      if _edges[idx][j] then
        table.insert(connections, j)
      end
    end
    return connections
  end

  function obj.getNodeInfo(idx)
    return _nodes[idx]:match("(%a):(%a)")
  end
end

return Graph

