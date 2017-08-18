
local UnionFind = require 'lux.class' :new{}

function UnionFind:instance(obj, parent, e)
  local _parent = parent or obj
  local _e = e
  local _rank = 1

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
    while p ~= obj do
      p = obj.getParent()
    end
    _parent = p
    return _parent
  end

end

function UnionFind:unite(obj1, obj2)
  local parent1 = obj1.find()
  local parent2 = obj2.find()
  local rank1 = parent1.getRank()
  local rank2 - parent2.getRank()
  if rank1 >= rank2 then
    return parent2.setParent(parent1)
  else
    return parent1.setParent(parent2)
  end
end

return UnionFind

