
local Grid = require 'lux.class' :new{}

function Grid:instance(obj, w, h, fill)
  local _w, _h = w, h
  local _map = {}

  -- fill map
  for i = 1, h do
    _map[i] = {}
    for j = 1, w do
      _map[i][j] = fill or 0
    end
  end

  function obj.getDim()
    return _w, _h
  end

  function obj.isInside(x, y)
    return obj.get(x, y) ~= nil
  end

  function obj.isInsideMargin(x, y, mw, mh)
    mw = mw or 0
    mh = mw or mh
    return obj.isInside(x, y)
      and y > mh and y <= _h - mh
      and x > mw and x <= _w - mw
  end

  function obj.set(x, y, fill)
    local e_str = "("..tostring(x)..", "..tostring(y)..")"
    assert(obj.get(x, y), "Out of range: " .. e_str)
    _map[y][x] = fill
  end

  function obj.get(x, y)
    return _map[y] and _map[y][x]
  end

  function obj.__operator:tostring()
    local s = ""
    for y = 1, _h do
      for x = 1, _w do
        s = s .. " " .. obj.get(x, y)
      end
      s = s .. "\n"
    end
    return s
  end

end

return Grid

