
-- dependencies
local Helpers = require 'lux.pack' 'domain.transformers.helpers'
local Vector2  = require 'cpml.modules.vec2'

local schematics = Helpers.schematics

return function (map, params)
  local width, height = map.getDim()
  local mw, mh = map.getMargins()

  local minx = mw + 1
  local miny = mh + 1
  local maxx = width - mw
  local maxy = height - mh

  local n = params.n
  local cardinals = {
    Vector2( 1,  0),
    Vector2( 0,  1),
    Vector2(-1,  0),
    Vector2( 0, -1)
  }

  local function isCorner(point)
    local FLOOR = schematics.FLOOR
    local notwall = false
    local count = 0
    for i, dir in ipairs(cardinals) do
      local pos = point + dir
      if map.get(pos.x, pos.y) ~= FLOOR then
        count = count + 1
      else
        notwall = pos
      end
    end
    if count == 3 then
      return notwall
    else
      print("end")
      return false
    end
  end

  local function cleanCorner(corner)
    local NAUGHT = schematics.NAUGHT
    while corner and isCorner(corner) do
      map.set(corner.x, corner.y, NAUGHT)
      corner = isCorner(corner)
    end
    n = n - 1
  end

  local function removeDeadEnds()
    local FLOOR = schematics.FLOOR
    local corner
    for y = miny, maxy do
      for x = minx, maxx do
        if n == 0 then return map end
        if map.get(x, y) == FLOOR then
          corner = Vector2(x, y)
          if isCorner(corner) then cleanCorner(corner) end
        end
      end
    end
    return map
  end

  return removeDeadEnds()
end


