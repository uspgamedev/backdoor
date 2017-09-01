
local SectorGrid = require 'lux.class' :new{}
local SCHEMATICS = require 'definitions.schematics'

function SectorGrid:instance(obj, w, h, mw, mh)
  local _w, _h = w, h
  local _mw, _mh = mw, mh
  local _sector = {}
  local _content = {}

  -- fill sector
  for i = 1, h do
    _sector[i] = {}
    for j = 1, w do
      _sector[i][j] = SCHEMATICS.NAUGHT
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

  function obj.addContent(e)
    table.insert(_content, e)
  end

  function obj.set(x, y, fill)
    local e_str = "("..tostring(x)..", "..tostring(y)..")"
    assert(obj.get(x, y), "Out of range: " .. e_str)
    _sector[y][x] = fill
  end

  function obj.get(x, y)
    return _sector[y] and _sector[y][x]
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

function SectorGrid:from(matrix, mw, mh)
  -- when we implement walls and other tiles, we'll need to update this method
  local h = #matrix
  local w = #matrix[1]
  mw = mw or 0
  mh = mh or 0
  local grid = SectorGrid(w, h, mw, mh)
  for i = 1, h do
    for j = 1, w do
      grid.set(j, i, matrix[i][j] and SCHEMATICS.FLOOR or SCHEMATICS.NAUGHT)
    end
  end
  return grid
end

return SectorGrid

