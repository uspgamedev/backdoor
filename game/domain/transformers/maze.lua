
-- dependencies
local HELPERS = require 'lux.pack' 'domain.transformers.helpers'
local Vector2  = require 'cpml.modules.vec2'

local Rectangle  = HELPERS.rect
local RANDOM     = HELPERS.random
local SCHEMATICS = HELPERS.schematics

return function (_mapgrid, params)
  local _width, _height = _mapgrid.getDim()
  local _mw, _mh = _mapgrid.getMargins()

  -- corridor positions
  local _minx = _mw + 1
  local _miny = _mh + 1
  local _maxx = _width - _mw
  local _maxy = _height - _mh

  -- params
  local _dist = 2 * (params.double and 2 or 1)
  local _cardinals = {
    Vector2( 1,  0) * _dist,
    Vector2( 0,  1) * _dist,
    Vector2(-1,  0) * _dist,
    Vector2( 0, -1) * _dist,
  }

  local _potentials = {}  -- { point, direction }
  local _maze_scheme = {} -- { point, direction }
  local _possible_starts = {}
  local _start

  local function isPointInScheme(point)
    for _, p in ipairs(_maze_scheme) do
      if p[1] + p[2] == point then return true end
    end
    return false
  end

  local function isValidPoint(point)
    local FLOOR = SCHEMATICS.FLOOR
    local x, y = point.x, point.y
    return _mapgrid.isInsideMargins(x, y)
           and _mapgrid.get(x, y) ~= SCHEMATICS.FLOOR
           and not isPointInScheme(point)
  end

  local function getAllPossibleStartPoints()
    local insert = table.insert
    local mx = _minx % 2 == 1 and _minx or _minx + 1
    local my = _miny % 2 == 1 and _miny or _miny + 1
    for x = mx, _maxx, 2 do
      for y = my, _maxy, 2 do
        local p = Vector2(x, y)
        if isValidPoint(p) then
          insert(_possible_starts, p)
        end
      end
    end
  end

  local function removePossibleStart(k)
    local N = #_possible_starts
    local possible_start = _possible_starts[k]
    _possible_starts[k] = _possible_starts[N]
    _possible_starts[N] = nil
    return possible_start
  end

  local function getPossibleStart(p)
    local N = #_possible_starts
    for k = 1, N do
      if _possible_starts[k] == p then
        return k
      end
    end
  end

  local function setStartPoint()
    local N = #_possible_starts
    local k = RANDOM.interval(1, N)
    _start = removePossibleStart(k)
  end

  local function addPotentialMovements()
    local insert = table.insert
    for _, dir in ipairs(_cardinals) do
      local newpoint = _start + dir
      if isValidPoint(newpoint) then
        insert(_potentials, { _start, dir })
      end
    end
  end

  local function getPotentialMovement()
    local N = #_potentials
    local movement
    local k

    if N == 0 then return false end

    local function removeFromPotentials(i)
      _potentials[i] = _potentials[N]
      _potentials[N] = nil
      N = #_potentials
    end

    repeat
      k = N > 1 and RANDOM.interval(N) or 1
      movement = _potentials[k]
      if not isValidPoint(movement[1] + movement[2]) then
        movement = false
      end
      removeFromPotentials(k)
    until movement or N <= 0

    return movement
  end

  local function generateMaze()
    local insert = table.insert
    local moveable
    repeat
      addPotentialMovements()
      moveable = getPotentialMovement()
      if moveable then
        _start = moveable[1] + moveable[2]
        insert(_maze_scheme, moveable)
        local k = getPossibleStart(_start)
        if k then removePossibleStart(k) end
      end
    until not moveable or #_potentials == 0
  end

  local function caveMaze()
    local FLOOR = SCHEMATICS.FLOOR
    local abs = math.abs
    for _, movement in ipairs(_maze_scheme) do
      local pos1, pos2 = movement[1], movement[1] + movement[2]
      local dx = (pos2.x - pos1.x) / abs(pos2.x - pos1.x)
      local dy = (pos2.y - pos1.y) / abs(pos2.y - pos1.y)
      for x = pos1.x, pos2.x, dx do
        _mapgrid.set(x, pos1.y, FLOOR)
      end
      for y = pos1.y, pos2.y, dy do
        _mapgrid.set(pos1.x, y, FLOOR)
      end
    end
    return _mapgrid
  end

  getAllPossibleStartPoints()
  while #_possible_starts > 0 do
    setStartPoint()
    generateMaze()
  end
  return caveMaze()
end


