
-- dependencies
local Helpers = require 'lux.pack' 'domain.transformers.helpers'
local Vector2  = require 'cpml.modules.vec2'

local Rectangle  = Helpers.rect
local random     = Helpers.random
local schematics = Helpers.schematics

return function (map, params)
  local width, height = map.getDim()
  local mw, mh = map.getMargins()

  -- corridor positions
  local minx = mw + 1
  local miny = mh + 1
  local maxx = width - mw
  local maxy = height - mh
  local dist = 2 * (params.double and 2 or 1)
  local cardinals = {
    Vector2( 1,  0) * dist,
    Vector2( 0,  1) * dist,
    Vector2(-1,  0) * dist,
    Vector2( 0, -1) * dist,
  }

  local potentials = {}  -- { point, direction }
  local maze_scheme = {} -- { point, direction }
  local start

  local function isPointInScheme(point)
    for _, p in ipairs(maze_scheme) do
      if p[1] + p[2] == point then return true end
    end
    return false
  end

  local function isValidPoint(point)
    local FLOOR = schematics.FLOOR
    local x, y = point.x, point.y
    return map.isInsideMargins(x, y)
      and map.get(x, y) ~= schematics.FLOOR
      and not isPointInScheme(point)
  end

  local function setStartPoint()
    repeat start = Vector2(random.odd(minx, maxx), random.odd(miny, maxy))
    until isValidPoint(start)
  end

  local function addPotentialMovements()
    local insert = table.insert
    for _, dir in ipairs(cardinals) do
      local newpoint = start + dir
      if isValidPoint(newpoint) then
        insert(potentials, { start, dir })
      end
    end
  end

  local function getPotentialMovement()
    local N = #potentials
    local movement
    local k

    local function removeFromPotentials(i)
      potentials[i] = potentials[N]
      potentials[N] = nil
      N = #potentials
    end

    repeat
      k = random.interval(1, N)
      movement = potentials[k]
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
        start = moveable[1] + moveable[2]
        insert(maze_scheme, moveable)
      end
    until not moveable or #potentials == 0
  end

  local function caveMaze()
    local FLOOR = schematics.FLOOR
    local abs = math.abs
    for _, movement in ipairs(maze_scheme) do
      local pos1, pos2 = movement[1], movement[1] + movement[2]
      local dx = (pos2.x - pos1.x) / abs(pos2.x - pos1.x)
      local dy = (pos2.y - pos1.y) / abs(pos2.y - pos1.y)
      for x = pos1.x, pos2.x, dx do
        map.set(x, pos1.y, FLOOR)
      end
      for y = pos1.y, pos2.y, dy do
        map.set(pos1.x, y, FLOOR)
      end
    end
    return map
  end

  setStartPoint()
  generateMaze()
  return caveMaze()
end


