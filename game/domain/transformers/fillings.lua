
local SCHEMATICS = require 'domain.definitions.schematics'

local transformer = {}

transformer.schema = {}

function transformer.process(sectorinfo, _)
  local sectorgrid = sectorinfo.grid
  local potentials, n

  local function _findPotentials(tile_type)
    potentials = potentials or {}
    n = 0
    for x, y, _ in sectorgrid.iterate() do
      if sectorgrid.isInsideMargins(x, y)
        and sectorgrid.get(x, y) == tile_type then
        local count = 0
        for j = x-1, x+1 do
          for i = y-1, y+1 do
            if not (j == x and y == i) then
              if sectorgrid.get(j, i) == tile_type then
                count = count + 1
              end
            end
          end
        end
        if count <= 1 then
          n = n + 1
          potentials[n] = {x, y}
        end
      end
    end
  end

  repeat
    _findPotentials(SCHEMATICS.NAUGHT)
    _findPotentials(SCHEMATICS.WALL)
    if n > 0 then
      for idx = 1, n do
        local x, y = unpack(potentials[idx])
        sectorgrid.set(x, y, SCHEMATICS.FLOOR)
      end
    end
  until n == 0

  return sectorinfo
end

return transformer

