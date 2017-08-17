
-- dependencies
local Helpers = require 'lux.pack' 'domain.transformers.helpers'

local Rectangle  = Helpers.rect
local random     = Helpers.random
local schematics = Helpers.schematics

-- localify
local floor = math.floor

return function (map, params)
  local width  = map.getWidth()
  local height = map.getHeight()
  local minw = params.minw
  local minh = params.minh
  local maxw = params.maxw
  local maxh = params.maxh
  local count = params.count
  local tries = params.tries
  local rmargin = 3

  local minx = mw + 1
  local miny = mh + 1
  local maxx = width - mw
  local maxy = height - mh

  local rooms = {}

  local function makeOneRoom()
    return Rectangle(
      Rand.odd(minx, maxx), Rand.odd(miny, maxy),
      Rand.odd(minw, maxw), Rand.odd(minh, maxh)
    )
  end

  local function isRoomIntersecting(room)
    local try = 0
    local N = #rooms
    local cpos = room.getPos()
    local cdim = room.getDim()
    local copy = Rectangle(
      cpos.x - rmargin - 1,
      cpos.y - rmargin - 1,
      cdim.x + rmargin * 2 + 1,
      cdim.y + rmargin * 2 + 1)
    for i = 1, N do
      if copy.intersect(rooms[i]) then return true end
    end
    return false
  end

  local function isRoomInsideMap(room)
    local max = room.getMax()
    return map.isInsideMargin(max.x, max.y)
  end

  local function generateRooms ()
    local insert = table.insert
    for i = 1, count do
      insert(rooms, (function ()
        local room
        repeat
          tries = tries - 1
          room = makeOneRoom()
        until tries == 0 or isRoomInsideMap(room, map) and not isRoomIntersecting(room)
        return room
      end)())
    end
  end

  local function caveRooms()
    for _, room in ipairs(rooms) do
      local min, max = room.getMin(), room.getMax()
      for x = min.x, max.x do
        for y = min.y, max.y do
          map.set(x, y, schematics.FLOOR)
        end
      end
    end
    return map
  end

  generateRooms()
  return caveRooms()
end

