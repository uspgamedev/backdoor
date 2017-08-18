
local MapGrid = require 'lux.class' :new{}
local SCHEMATICS = require 'domain.transformers.helpers.schematics'

function MapGrid:instance(obj, w, h, mw, mh)
  local _w, _h = w, h
  local _mw, _mh = mw, mh
  local _map = {}

  -- fill map
  for i = 1, h do
    _map[i] = {}
    for j = 1, w do
      _map[i][j] = SCHEMATICS.NAUGHT
    end
  end

  function obj.getDim()
    return _w, _h
  end

  function obj.isInside(x, y)
    return x >= 1 and x <= _w and y >= 1 and y <= _h
  end

  function obj.getMargins()
    return _mw, _mh
  end

  function obj.isInsideMargins(x, y)
    return y > _mh and y <= _h - _mh and x > _mw and x <= _w - _mw
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

return MapGrid

