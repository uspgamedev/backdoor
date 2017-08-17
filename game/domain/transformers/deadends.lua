
-- dependencies
local Helpers = require 'lux.pack' 'domain.transformers.helpers'
local Vector2 = require 'cpml.modules.vec2'

local schematics = Helpers.schematics
local random     = Helpers.random

return function (_map, _params)
  local _width, _height = _map.getDim()
  local _mw, _mh = _map.getMargins()

  local _minx = _mw + 1
  local _miny = _mh + 1
  local _maxx = _width - _mw
  local _maxy = _height - _mh

  local _n = _params.n
  local _cardinals = {
    Vector2( 1,  0),
    Vector2( 0,  1),
    Vector2(-1,  0),
    Vector2( 0, -1)
  }

  local function isCorner(point)
    local FLOOR = schematics.FLOOR
    local notwall = false
    local count = 0
    for i, dir in ipairs(_cardinals) do
      local pos = point + dir
      if _map.get(pos.x, pos.y) ~= FLOOR then
        count = count + 1
      else
        notwall = pos
      end
    end
    if count == 3 then
      return notwall
    else
      return false
    end
  end

  local function cleanCorner(corner)
    local NAUGHT = schematics.NAUGHT
    while corner and isCorner(corner) do
      _map.set(corner.x, corner.y, NAUGHT)
      corner = isCorner(corner)
    end
  end

  local function removeDeadEnds()
    local FLOOR = schematics.FLOOR
    local corner
    while _n > 0 do
      if _n == 0 then return _map end
      local x = random.odd(_minx, _maxx)
      local y = random.odd(_miny, _maxy)
      if _map.get(x, y) == FLOOR then
        corner = Vector2(x, y)
        if isCorner(corner) then
          cleanCorner(corner)
          _n = _n - 1
        end
      end
    end
    return _map
  end

  return removeDeadEnds()
end


