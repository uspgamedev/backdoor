
local DIR  = require 'domain.definitions.dir'
local Heap = require 'common.heap'
local TILE = require 'common.tile'


-- CONSTANTS --

local _DEDICATION = 32
local _LIMIT = 64


-- LOCAL FUNCTIONS --

local function _hash(pos, width)
  if not pos then return "none" end
  local i, j = unpack(pos)
  return i * width + j
end

local function _heuristic(pos1, pos2)
  local i1, j1 = unpack(pos1)
  local i2, j2 = unpack(pos2)
  return TILE.dist(i1, j1, i2, j2)
end


-- MODULE METHODS --

local FindPath = {}

function FindPath.getNextStep(start, goal, sector)
  local frontier = Heap:new()
  local came_from = {}
  local cost_so_far = {}
  local path = {}
  local found = false
  local iterations = 0
  local swidth = sector:getDimensions()

  frontier:add(start, 0)
  came_from[_hash(start, swidth)] = true
  cost_so_far[_hash(start, swidth)] = 0

  while not frontier:isEmpty() do
    iterations = iterations + 1
    local current, rank = frontier:getNext()

    -- if you found your goal, quit loop
    if _heuristic(goal, current) == 1 then
      found = true
      goal = current
      break
    end

    if iterations >= _LIMIT then break end

    -- look at neighbors
    for _,dir in ipairs(DIR) do
      local di, dj = unpack(DIR[dir])
      local i, j = unpack(current)
      local ti, tj = unpack(goal)
      local next_pos = { i+di, j+dj }
      local distance = _heuristic(goal, next_pos)

      if sector:isValid(unpack(next_pos)) and distance < _DEDICATION then
        local new_cost = cost_so_far[_hash(current, swidth)] + 1

        -- is it a valid and not yet checked neighbor?
        if not cost_so_far[_hash(next_pos, swidth)]
          or new_cost < cost_so_far[_hash(next_pos, swidth)] then
          local new_rank = new_cost + 2 * distance
          cost_so_far[_hash(next_pos, swidth)] = new_cost
          came_from[_hash(next_pos, swidth)] = current
          frontier:add(next_pos, new_rank)
        end
      end
    end
  end

  local current = goal
  if found then
    while _hash(start, swidth) ~= _hash(current, swidth) do
      table.insert(path, current)
      current = came_from[_hash(current, swidth)]
    end
    return path[#path]
  end
  return false
end

return FindPath

