
local UnionFind = require 'lux.class' :new{}

function UnionFind:instance(obj, e)
  local _parent = obj
  local _rank = 1
  local _e = e

  function obj.getElement()
    return _e
  end

  function obj.getParent()
    return _parent
  end

  function obj.setParent(p)
    p.addRank(_rank)
    _parent = p
    return _parent
  end

  function obj.addRank(i)
    _rank = _rank + i
  end

  function obj.getRank()
    return _rank
  end

  function obj.find()
    if _parent == obj then return obj end
    local p = _parent
    while p ~= p.getParent() do
      p = p.getParent()
    end
    _parent = p
    return _parent
  end

end

function UnionFind:unite(obj1, obj2)
  local p1 = obj1.find()
  local p2 = obj2.find()
  if p1.getRank() >= p2.getRank() then
    return p2.setParent(p1)
  else
    return p1.setParent(p2)
  end
end

return UnionFind
