
local DIR = require 'domain.definitions.dir'
local Action = require 'domain.action'
local TILE = require 'common.tile'

local function _hash(pos)
  if not pos then return "none" end
  return string.format("%d:%d", unpack(pos))
end

local function get_path(start, goal, sector)
  local frontier, head = {start}, 1
  local came_from = {}
  local path = {}
  local found = false

  came_from[_hash(start)] = start

  while head <= #frontier do
    local current = frontier[head]
    head = head + 1

    if TILE.distUniform(goal[1], goal[2], unpack(current)) == 1 then
      found = true
      goal = current
      break
    end

    for n = 1, 4 do
      local i, j = unpack(current)
      local di, dj = unpack(DIR[DIR[n]])
      local next_pos = { i+di, j+dj }

      if not came_from[_hash(next_pos)]
        and sector:isValid(unpack(next_pos)) then
        came_from[_hash(next_pos)] = current
        table.insert(frontier, next_pos)
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

return function (actor, sector)
  local actorlist = sector:getActors()
  local target, dist
  local i, j = actor:getPos()

  -- create list of opponents
  for _,opponent in ipairs(actorlist) do
    if opponent:isPlayer() then
      local k, l = opponent:getPos()
      local d = TILE.distUniform(i, j, k, l)
      if not target or not dist or d < dist then
        target = opponent
        dist = d
      end
    end
  end

  if dist == 1 then
    -- attack if close!
    return 'PRIMARY', { target = {target:getPos()} }
  elseif dist <= 5 then
    -- chase if far away!
    local pos = get_path({i,j}, {target:getPos()}, sector)
    if pos then
      return 'MOVE', { pos = pos }
    end
  end

  return 'IDLE', {}
end

