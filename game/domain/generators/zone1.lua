
-- dependencies
local floor = math.floor
local Rectangle = require 'domain.generators.helpers.rect'
local Grid = require 'domain.generators.helpers.grid'
local Rand = require 'domain.generators.helpers.random'

-- static consts
local NAUGHT = "*"
local FLOOR  = " "
local WALL   = "#"

-- parametres
local width = 32
local height = 32
local margin = 2
local room_margin = 2
local min_rw, min_rh = 3, 3
local max_rw, max_rh = 9, 9

local room_count = 5

local useful_pos = {
  margin + 1,
  width - margin,
  margin + 1,
  height - margin
}

-- validators
local function isRoomIntersecting(room, room_list)
  local N = #room_list
  local cpos = room.getPos()
  local cdim = room.getDim()
  local copy = Rectangle(
    cpos.x - room_margin - 1,
    cpos.y - room_margin - 1,
    cdim.x + room_margin * 2 + 1,
    cdim.y + room_margin * 2+ 1)
  for i = 1, N do
    if copy.intersect(room_list[i]) then return true end
  end
  return false
end

local function isRoomInsideMap(room, map)
  local max = room.getMax()
  return map.isInsideMargin(max.x, max.y, margin)
end

-- generators
local function makeOneRoom()
  return Rectangle(
    Rand.odd(useful_pos[1], useful_pos[2]),
    Rand.odd(useful_pos[3], useful_pos[4]),
    Rand.interval(min_rw, max_rw),
    Rand.interval(min_rh, max_rh)
  )
end

local function makeRoomsForMap (map)
  local rooms = {}
  for i = 1, room_count do
    table.insert(rooms, (function ()
      local rect
      repeat
        rect = make_one_room()
      until isRoomInsideMap(rect, map) and not isRoomIntersecting(rect, rooms)
      return rect
    end)())
  end
  return rooms
end

local function caveRooms(map, rooms)
  for _, room in ipairs(rooms) do
    local min, max = room.getMin(), room.getMax()
    for x = min.x, max.x do
      for y = min.y, max.y do
        map.set(x, y, FLOOR)
      end
    end
  end
end

-- final generator
return function ()
  local map = Grid(width, height, WALL)
  local rooms = makeRoomsForMap(map)
  caveRooms(map, rooms)

  -- finished, print
  return map
end



