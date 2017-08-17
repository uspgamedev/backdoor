
-- dependencies
local Helpers = require 'lux.pack' 'domain.transformers.helpers'
local Queue   = require 'lux.common.Queue'
local Vector2  = require 'cpml.modules.vec2'

local Rectangle  = Helpers.rect
local random     = Helpers.random
local schematics = Helpers.schematics

return function (map, params)
  local progress = Queue(64)

  local mw, mh = map.getMargins()
  local minx = mw + 1
  local miny = mh + 1
  local maxx = map.getWidth() - mw
  local maxy = map.getHeight() - mh
  local dist = 2 * (params.double and 2 or 1)
  local cardinals = {
    dist * Vector2(+1,  0),
    dist * Vector2( 0, +1),
    dist * Vector2(-1,  0),
    dist * Vector2( 0, -1),
  }

  local potentials = {}  -- { point, direction }
  local maze_scheme = {} -- { point, direction }
  local start

  local function isValidPoint(point)
    local FLOOR = schematics.FLOOR
    local x, y = point.x, point.y
    return map.isInsideMargins(x, y)
      and map.get(x, y) ~= schematics.FLOOR
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
    local k = random.interval(1, N)
    local movement = potentials[k]
    potentials[k] = potentials[N]
    potentials[N] = nil
    return isValidPoint(movement[1] + movement[2]) and movement
  end

  local function generateMaze()
    local insert = table.insert
    local moveable
    repeat
      addPotentialMovements()
      moveable = getPotentialMovement()
      if moveable then
        start = moveable[1] moveable[2]
        insert(maze_scheme, moveable)
      end
    until not moveable or #potentials == 0
  end

  local function caveMaze()
    local FLOOR = schematics.FLOOR
    for _, movement in ipairs(maze_scheme) do
      local pos1, pos2 = movement[1], movement[1] + movement[2]
      for x = pos1.x, pos2.x do
        map.set(x, po1.y, FLOOR)
      end
      for y = pos1.y, pos2.y do
        map.set(pos1.x, y, FLOOR)
      end
    end
    return map
  end

  setStartPoint()
  generateMaze()
  return caveMaze()
end


