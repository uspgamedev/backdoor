
-- dependencies
local HELPERS = require 'lux.pack' 'domain.transformers.helpers'
local Vector2  = require 'cpml.modules.vec2'

local Rectangle  = HELPERS.rect
local UnionFind  = HELPERS.unionfind
local RANDOM     = HELPERS.random
local SCHEMATICS = HELPERS.schematics

return function (_mapgrid, _params)
  local _width, _height = _mapgrid.getDim()
  local _mw, _mh = _mapgrid.getMargins()

  -- valid positions
  local _minx = _mw + 1
  local _miny = _mh + 1
  local _maxx = _width - _mw
  local _maxy = _height - _mh

  -- lists and sets
  local _connections = _params.n
  local _flooded = {}
  local _connectors = {}
  local _cardinals = {
    Vector2( 1,  0),
    Vector2( 0,  1),
    Vector2(-1,  0),
    Vector2( 0, -1)
  }


  local function getId(x, y)
    return _width * (y - 1) + (x - 1)
  end

  local function connectTwoRegions(r1, r2, p)
    local union = UnionFind(getId(p.x, p.y))
    local id1 = r1.getElement()
    local id2 = r2.getElement()
    union = UnionFind:unite(union, r1)
    union = UnionFind:unite(union, r2)
    _flooded[union.getElement()] = union
    print("connecting:", p)
    _mapgrid.set(p.x, p.y, SCHEMATICS.FLOOR)
  end

  local function getFloorNeighbours(x, y)
    local FLOOR = SCHEMATICS.FLOOR
    local insert = table.insert
    local neighbours = {}
    local pos = Vector2(x, y)
    for i, dir in ipairs(_cardinals) do
      local p = pos + dir
      if _mapgrid.get(p.x, p.y) == FLOOR then
        insert(neighbours, p)
      end
    end
    return neighbours
  end

  local function floodOneRegion(x, y)
    local id = getId(x, y)
    local region

    -- recursion base
    if _flooded[id] then
      return _flooded[id]
    end

    -- general case
    region = UnionFind(id)
    _flooded[id] = region
    local sides = getFloorNeighbours(x, y)
    for _, side in ipairs(sides) do
      local sx, sy = side.x, side.y
      region = UnionFind:unite(region, floodOneRegion(sx, sy))
    end

    return region
  end

  local function floodRegions()
    local FLOOR = SCHEMATICS.FLOOR
    local insert = table.insert
    for x = _minx, _maxx do
      for y = _miny, _maxy do
        local id = getId(x, y)
        if _mapgrid.get(x, y) == FLOOR then
          if not _flooded[id] then
            floodOneRegion(x, y)
          end
        else
          local sides = getFloorNeighbours(x, y)
          if #sides == 2 then
            local id1 = getId(sides[1].x, sides[1].y)
            local id2 = getId(sides[2].x, sides[2].y)
            local c = { Vector2(x, y), { id1, id2 } }
            insert(_connectors, c)
          end
        end
      end
    end
  end

  local function countRegions()
    local counted = {}
    local count = 0
    for id, region in pairs(_flooded) do
      local k = region.find()
      if not counted[k] then
        count = count + 1
        counted[k] = true
      end
    end
    return count
  end

  local function connectAllRegions()
    while countRegions() > 1 and #_connectors > 0 do
      if _connections <= 0 then break end
      local N = #_connectors
      local k = N > 1 and RANDOM.interval(1, N) or 1
      local c = _connectors[k]
      local r1 = _flooded[c[2][1]].find()
      local r2 = _flooded[c[2][2]].find()
      _connectors[k] = _connectors[N]
      _connectors[N] = nil
      _connections = _connections - 1
      connectTwoRegions(r1, r2, c[1])
    end
    return _mapgrid
  end

  floodRegions()
  return connectAllRegions()
end
