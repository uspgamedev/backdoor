
local SCHEMATICS = require 'domain.definitions.schematics'

local SectorGrid = require 'lux.class' :new{}

function SectorGrid:instance(obj, w, h, mw, mh)
  local _w, _h = w, h
  local _mw, _mh = mw, mh
  local _grid = {}

  -- fill sector
  for i = 1, h do
    _grid[i] = {}
    for j = 1, w do
      _grid[i][j] = SCHEMATICS.NAUGHT
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
    _grid[y][x] = fill
  end

  function obj.get(x, y)
    return _grid[y] and _grid[y][x]
  end

  function obj.iterate ()
    local init_s = { 1, 0, tbl = _grid }
    return function(s, value)
      local m = s.tbl

      s[2] = s[2] + 1
      i, j = s[1], s[2]
      value = m[i] and m[i][j]

      if not value then
        s[1] = s[1] + 1
        s[2] = 1
        i, j = s[1], s[2]
        value = m[i] and m[i][j]
      end

      return value and j, i, value
    end,
    init_s,
    0
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
      grid.set(j, i, matrix[i][j] or false)
    end
  end
  return grid
end

return SectorGrid

