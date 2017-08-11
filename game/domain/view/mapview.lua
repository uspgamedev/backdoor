
local TILE_W = 80
local TILE_H = 80

local MapView = Class {
  __includes = { ELEMENT }
}

function MapView:init(map)

  ELEMENT.init(self)

  self.map = map

end

function MapView:setMap(map)
  self.map = map
end

function MapView:draw()
  local map = self.map
  local g = love.graphics
  for i = 0, map.h-1 do
    for j = 0, map.w-1 do
      local tile = map.tiles[i+1][j+1]
      local body = map.bodies[i+1][j+1]
      local x, y = j*TILE_W, i*TILE_H
      g.push()
      g.translate(x, y)
      g.setColor(tile)
      g.rectangle("fill", 0, 0, TILE_W, TILE_H)
      if body then
        g.push()
        g.translate(TILE_W/2, TILE_H/2)
        g.scale(TILE_W, TILE_H)
        g.setColor(200, 100, 100)
        g.polygon('fill', 0.0, -0.8, -0.25, 0.0, 0.0, 0.2)
        g.setColor(90, 140, 140)
        g.polygon('fill', 0.0, -0.8, 0.25, 0.0, 0.0, 0.2)
        g.pop()
        g.print(body.hp, 0, 0)
      end
      g.pop()
    end
  end

end

return MapView
