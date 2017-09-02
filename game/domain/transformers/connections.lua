
-- dependencies
local SCHEMATICS = require 'definitions.schematics'
local RANDOM     = require 'common.random'
local Rectangle  = require 'common.rect'
local UnionFind  = require 'common.unionfind'
local Vector2    = require 'cpml.modules.vec2'

local transformer = {}

transformer.schema = {
  { id = 'loops', name = "Num Connections", type = 'integer',
    range = { 1, 1024 } }
}

function transformer.process(_sectorgrid, params)
  local _width, _height = _sectorgrid.getDim()
  local _mw, _mh = _sectorgrid.getMargins()

  -- valid positions
  local _minx = _mw + 1
  local _miny = _mh + 1
  local _maxx = _width - _mw
  local _maxy = _height - _mh

  -- lists and sets
  local _loops = params.loops
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
    _sectorgrid.set(p.x, p.y, SCHEMATICS.FLOOR)
  end

  local function getFloorNeighbours(x, y)
    local FLOOR = SCHEMATICS.FLOOR
    local insert = table.insert
    local neighbours = {}
    local pos = Vector2(x, y)
    for i, dir in ipairs(_cardinals) do
      local p = pos + dir
      if _sectorgrid.get(p.x, p.y) == FLOOR then
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

  local function checkIfConnection(x, y)
    local insert = table.insert
    local sides = getFloorNeighbours(x, y)
    if #sides == 2 then
      if sides[1]:dist2(sides[2]) == 4 then
        local id1 = getId(sides[1].x, sides[1].y)
        local id2 = getId(sides[2].x, sides[2].y)
        local c = { Vector2(x, y), { id1, id2 } }
        insert(_connectors, c)
      end
    end
  end

  local function floodRegions()
    local FLOOR = SCHEMATICS.FLOOR
    for x = _minx, _maxx do
      for y = _miny, _maxy do
        local id = getId(x, y)
        if _sectorgrid.get(x, y) == FLOOR then
          if not _flooded[id] then
            floodOneRegion(x, y)
          end
        else
          checkIfConnection(x, y)
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
    local insert = table.insert
    local copy_connectors = {}
    local N = #_connectors
    while countRegions() > 1 and N > 0 do
      local k, c, r1, r2
      repeat
        k = N > 1 and RANDOM.interval(1, N) or 1
        c = _connectors[k]
        r1 = _flooded[c[2][1]].find()
        r2 = _flooded[c[2][2]].find()
        _connectors[k] = _connectors[N]
        _connectors[N] = nil
        N = N - 1
        if r1 == r2 then insert(copy_connectors, c) end
      until r1 ~= r2 or N == 0
      connectTwoRegions(r1, r2, c[1])
    end
    return copy_connectors
  end

  local function makeLoops(connectors)
    local N = #connectors
    while N > 0 do
      if _loops <= 0 then break end
      local k = N > 1 and RANDOM.interval(1, N) or 1
      local c = connectors[k]
      local r1 = _flooded[c[2][1]].find()
      local r2 = _flooded[c[2][2]].find()
      connectors[k] = connectors[N]
      connectors[N] = nil
      _loops = _loops - 1
      N = N - 1
      connectTwoRegions(r1, r2, c[1])
    end
    return _sectorgrid
  end

  floodRegions()
  return makeLoops(connectAllRegions())
end

return transformer

