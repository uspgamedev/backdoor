
local DIR = require 'domain.definitions.dir'
local ACTIONDEFS = require 'domain.definitions.action'
local Action = require 'domain.action'
local TILE = require 'common.tile'
local Heap = require 'common.heap'

local abs = math.abs
local VISION = 8
local DEDICATION = VISION * 4
local LIMIT = DEDICATION * 2
local WIDTH = 1

local function _hash(pos)
  if not pos then return "none" end
  local i, j = unpack(pos)
  return i*WIDTH + j
end

local function _heuristic(pos1, pos2)
  local i1, j1 = unpack(pos1)
  local i2, j2 = unpack(pos2)
  return TILE.dist(i1, j1, i2, j2)
end

local function _findPath(start, goal, sector)
  local frontier = Heap:new()
  local came_from = {}
  local cost_so_far = {}
  local path = {}
  local found = false
  local iterations = 0
  WIDTH = sector:getDimensions()

  frontier:add(start, 0)
  came_from[_hash(start)] = true
  cost_so_far[_hash(start)] = 0

  while not frontier:isEmpty() do
    iterations = iterations + 1
    local current, rank = frontier:getNext()

    -- if you found your goal, quit loop
    if _heuristic(goal, current) == 1 then
      found = true
      goal = current
      break
    end

    if iterations >= LIMIT then break end

    -- look at neighbors
    for _,dir in ipairs(DIR) do
      local di, dj = unpack(DIR[dir])
      local i, j = unpack(current)
      local ti, tj = unpack(goal)
      local next_pos = { i+di, j+dj }
      local distance = _heuristic(goal, next_pos)

      if sector:isValid(unpack(next_pos)) and distance < DEDICATION then
        local new_cost = cost_so_far[_hash(current)] + 1

        -- is it a valid and not yet checked neighbor?
        if not cost_so_far[_hash(next_pos)]
          or new_cost < cost_so_far[_hash(next_pos)] then
          local new_rank = new_cost + 2 * distance
          cost_so_far[_hash(next_pos)] = new_cost
          came_from[_hash(next_pos)] = current
          frontier:add(next_pos, new_rank)
        end
      end
    end
  end

  local current = goal
  if found then
    while _hash(start) ~= _hash(current) do
      table.insert(path, current)
      current = came_from[_hash(current)]
    end
    return path[#path]
  end
  return false
end

return function (actor)
  local target, dist
  local sector = actor:getBody():getSector()
  local i, j = actor:getPos()

  -- create list of opponents
  for _,opponent in sector:iterateActors() do
    if opponent:isPlayer() then
      local k, l = opponent:getPos()
      local d = _heuristic({i, j}, {k, l})
      if not target or not dist or d < dist then
        target = opponent
        dist = d
      end
    end
  end

  if dist == 1 then
    -- attack if close!
    return ACTIONDEFS.USE_SIGNATURE, { target = {target:getPos()} }
  elseif dist <= VISION then
    -- chase if far away!
    local pos = _findPath({i,j}, {target:getPos()}, sector)
    if pos then
      return ACTIONDEFS.MOVE, { pos = pos }
    end
  end

  return ACTIONDEFS.IDLE, {}
end

