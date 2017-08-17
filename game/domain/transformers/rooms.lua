
-- dependencies
local HELPERS = require 'lux.pack' 'domain.transformers.helpers'

local Rectangle  = HELPERS.rect
local random     = HELPERS.random
local schematics = HELPERS.schematics

return function (map, params)
  local _width, _height = map.getDim()
  local _mw, _mh = map.getMargins()

  -- room dimensions
  local _minw = params.minw
  local _minh = params.minh
  local _maxw = params.maxw
  local _maxh = params.maxh
  local _rmargin = 3

  -- room quantities
  local _count = params.count
  local _tries = params.tries

  -- room positions
  local _minx = _mw + 1
  local _miny = _mh + 1
  local _maxx = _width - _mw
  local _maxy = _height - _mh

  local _rooms = {}

  local function makeOneRoom()
    return Rectangle(
      random.odd(_minx, _maxx), random.odd(_miny, _maxy),
      random.even(_minw, _maxw), random.even(_minh, _maxh)
    )
  end

  local function isRoomIntersecting(room)
    local try = 0
    local N = #_rooms
    local cpos = room.getPos()
    local cdim = room.getDim()
    local copy = Rectangle(
      cpos.x - _rmargin - 1,
      cpos.y - _rmargin - 1,
      cdim.x + _rmargin * 2 + 1,
      cdim.y + _rmargin * 2 + 1)
    for i = 1, N do
      if copy.intersect(_rooms[i]) then return true end
    end
    return false
  end

  local function isRoomInsideMap(room)
    local max = room.getMax()
    return map.isInsideMargins(max.x, max.y)
  end

  local function generateRooms ()
    local insert = table.insert
    for i = 1, _count do
      insert(_rooms, (function ()
        local room
        repeat
          _tries = _tries - 1
          room = makeOneRoom()
        until _tries == 0 or isRoomInsideMap(room, map) and not isRoomIntersecting(room)
        return room
      end)())
    end
  end

  local function caveRooms()
    for _, room in ipairs(_rooms) do
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

