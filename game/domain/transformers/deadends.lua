
-- dependencies
local SCHEMATICS = require 'definitions.schematics'
local RANDOM     = require 'common.random'
local Vector2    = require 'cpml.modules.vec2'

local transformer = {}

function transformer.process(_sectorgrid, params)
  local _width, _height = _sectorgrid.getDim()
  local _mw, _mh = _sectorgrid.getMargins()

  local _minx = _mw + 1
  local _miny = _mh + 1
  local _maxx = _width - _mw
  local _maxy = _height - _mh

  local _corners = {}
  local _n = params.n
  local _cardinals = {
    Vector2( 1,  0),
    Vector2( 0,  1),
    Vector2(-1,  0),
    Vector2( 0, -1)
  }

  local function isCorner(point)
    local FLOOR = SCHEMATICS.FLOOR
    local notwall = false
    local count = 0
    for i, dir in ipairs(_cardinals) do
      local pos = point + dir
      if _sectorgrid.get(pos.x, pos.y) ~= FLOOR then
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
    local NAUGHT = SCHEMATICS.NAUGHT
    while corner and isCorner(corner) do
      _sectorgrid.set(corner.x, corner.y, NAUGHT)
      corner = isCorner(corner)
    end
  end

  local function getDeadEnds()
    local FLOOR = SCHEMATICS.FLOOR
    local insert = table.insert
    for x = _minx, _maxx do
      for y = _miny, _maxy do
        local p = Vector2(x, y)
        if _sectorgrid.get(x, y) == FLOOR then
          if isCorner(p) then
            insert(_corners, p)
          end
        end
      end
    end
  end

  local function removeDeadEnds()
    local FLOOR = SCHEMATICS.FLOOR
    local corner
    local len = #_corners
    if len == 0 then return false end
    while len > 0 do
      local k = RANDOM.interval(1, len)

      corner = _corners[k]
      _corners[k] = _corners[len]
      _corners[len] = nil
      len = #_corners
      if isCorner(corner) then
        cleanCorner(corner)
      end
    end
    return true
  end

  local try = 0
  while try < _n do
    try = try + 1
    getDeadEnds()
    if not removeDeadEnds() then
      return _sectorgrid
    end
  end
  return _sectorgrid
end

return transformer

