
-- dependencies
local vec2 = require 'cpml.modules.vec2'
local rand = math.random
local floor = math.floor

-- static consts
local FLOOR = 0
local WALL = 1

-- parametres
local width = 64
local height = 64
local margin = 2
local room_margin = 2
local min_rw, min_rh = 9, 9
local max_rw, max_rh = 25, 25
local room_count = floor(((width + height) / 2) /
  ((max_rw + max_rh) / 2)) ^ 2 - 1

-- generators
local function rectangle ()
  local rect = {}

  local pos = vec2(
    rand(1 + margin, width - margin),
    rand(1 + margin, height - margin)
  )
  local size = vec2(
    rand(min_rw, max_rw),
    rand(min_rh, max_rh)
  )

  function rect:get_pos ()
    return pos
  end

  function rect:get_size ()
    return size
  end

  function rect:get_max()
    return pos + size
  end

  rect.get_min = rect.get_pos

  function rect:intersect (rect2)
    local a, b = self, rect2
    local col = true
    local amin = a:get_min()
    local bmin = b:get_min()
    local amax = a:get_max()
    local bmax = b:get_max()
    if
      amin.x - room_margin > bmax.x or
      amin.y - room_margin > bmax.y or
      amax.x < bmin.x - room_margin or
      amax.y < bmin.y - room_margin then
      col = false
    end
    return col
  end

  return rect
end

local function make_rooms ()
  local rooms = {}
  for i = 1, room_count do
    table.insert(rooms, (function ()
      local rect
      repeat
        rect = rectangle()
      until (function ()
        local max = rect:get_max()
        if max.x > width - margin or max.y > height - margin then
          return false
        end
        for _, rect2 in ipairs(rooms) do
          if rect:intersect(rect2) then
            return false
          end
        end
        print(rect:get_max())
        return true
      end)()
      return rect
    end)())
  end
  return rooms
end

local function make_mt_map()
  local map = {}
  for i = 1, height do
    map[i] = {}
    for j = 1, width do
      map[i][j] = WALL
    end
  end
  return map
end

-- testing
make_mt_map()
make_rooms()

local function cave_rooms(map, rooms)
  for _, room in ipairs(rooms) do
    local min, max = room:get_min(), room:get_max()
    local size = room:get_size()
    print("caving room:", min, max)
    for i = min.y, max.y do
      for j = min.x, max.x do
        map[i][j] = FLOOR
      end
    end
  end
end

local function print_map(map)
  local s = ""
  for i = 1, height do
    for j = 1, width do
      s = s .. " " .. map[i][j]
    end
    s = s .. "\n"
  end
  print(s)
end

-- final generator
return function (...)
  local map = make_mt_map()
  local rooms = make_rooms()
  cave_rooms(map, rooms)

  -- finished, print
  print_map(map)
  return map
end



