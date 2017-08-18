
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
  local _dist = 2 * (params.double and 2 or 1)
  local _cardinals = {
    Vector2( 1,  0) * _dist,
    Vector2( 0,  1) * _dist,
    Vector2(-1,  0) * _dist,
    Vector2( 0, -1) * _dist,
  }

  local _potentials = {}  -- { point, direction }
  local _maze_scheme = {} -- { point, direction }
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

  local function setStartPoint()
    repeat _start = Vector2(RANDOM.odd(_minx, _maxx),
                            RANDOM.odd(_miny, _maxy))
    until isValidPoint(_start)
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

    local function removeFromPotentials(i)
      _potentials[i] = _potentials[N]
      _potentials[N] = nil
      N = #_potentials
    end

    repeat
      k = RANDOM.interval(1, N)
      movement = _potentials[k]
      if not isValidPoint(movement[1] + movement[2]) then
        movement = false
      end
      removeFromPotentials(k)
    until movement or N < 1

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

  setStartPoint()
  generateMaze()
  return caveMaze()
end


