
local Rectangle = require 'lux.class' :new{}

-- dependencies
local Vector2 = require 'cpml.modules.vec2'

function Rectangle:instance(obj, point1, point2)
  local _pos = Vector2(x, y)
  local _dim = Vector2(w, h)

  function obj.getPos ()
    return _pos
  end

  function obj.getDim ()
    return _dim
  end

  function obj.getMax()
    return _pos + _dim
  end

  obj.getMin = obj.getPos

  function obj.getParams()
    return _pos.x, _pos.y, _dim.x, _dim.y
  end

  function obj.intersect (obj2)
    local a, b = obj, obj2
    local amin = a.getMin()
    local bmin = b.getMin()
    local amax = a.getMax()
    local bmax = b.getMax()
    if amin.x > bmax.x or
      amin.y > bmax.y or
      amax.x < bmin.x or
      amax.y < bmin.y
      then return false
    end
    return true
  end

end

return Rectangle

