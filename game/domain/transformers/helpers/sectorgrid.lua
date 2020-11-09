
-- luacheck: no self

local SCHEMATICS = require 'domain.definitions.schematics'

local SectorGrid = require 'lux.class' :new{}

function SectorGrid:instance(obj, w, h, mw, mh, tiles)
  local _w, _h = w, h
  local _mw, _mh = mw, mh
  local _grid = {}
  tiles = tiles or {}

  -- fill sector
  for i = 1, h do
    _grid[i] = {}
    for j = 1, w do
      if (j > mw and j <= w - mw) and
         (i > mh and i <= h - mh) then
        _grid[i][j] = SCHEMATICS[tiles.fill or 'WALL']
      else
        _grid[i][j] = SCHEMATICS[tiles.margin or 'NAUGHT']
      end
    end
  end

  function obj.getWidth()
    return _w
  end

  function obj.getHeight()
    return _h
  end

  function obj.getDim()
    return _w, _h
  end

  function obj.getSize()
    return _w * _h
  end

  function obj.getRange()
    return _mw, _w - _mw, _mh, _h - _mh
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
    return function(s, _)
      local m = s.tbl

      s[2] = s[2] + 1
      local i, j = s[1], s[2]
      local value = m[i] and m[i][j]

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

function SectorGrid:copy(from)
  local w, h = from.getDim()
  local mw, mh = from.getMargins()
  local newgrid = SectorGrid(w, h, mw, mh)
  for x, y, tile in from.iterate() do
    newgrid.set(x, y, tile)
  end
  return newgrid
end

return SectorGrid

