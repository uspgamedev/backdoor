
local TILE_W = 80
local TILE_H = 80

local MapView = Class {
  __includes = { ELEMENT }
}

function MapView:init(map)

  ELEMENT.init(self)

  self.map = map
  self.target = nil

end

function MapView:setMap(map)
  self.map = map
end

function MapView:lookAt(target)
  self.target = target
end

function MapView:draw()
  local map = self.map
  local g = love.graphics
  g.setBackgroundColor(50, 80, 80, 255)
  do
    local x, y = CAM:position()
    local i, j = unpack(map:getActorPos(self.target))
    local tx, ty = (j-0.5)*TILE_W, (i-0.5)*TILE_H
    local smooth = 1/5
    CAM:move((tx - x)*smooth,(ty - y)*smooth)
  end
  for i = 0, map.h-1 do
    for j = 0, map.w-1 do
      local tile = map.tiles[i+1][j+1]
      if tile then
        local body = map.bodies[i+1][j+1]
        local x, y = j*TILE_W, i*TILE_H
        g.push()
        g.translate(x, y)
        g.setColor(tile)
        g.rectangle("fill", 0, 0, TILE_W, TILE_H)
        g.setColor(50, 50, 50)
        g.rectangle("fill", 0, TILE_H, TILE_W, TILE_H/4)
        if body then
          g.push()
          g.translate(TILE_W/2, TILE_H/2)
          g.scale(TILE_W, TILE_H)
          g.setColor(200, 100, 100)
          g.polygon('fill', 0.0, -0.8, -0.25, 0.0, 0.0, 0.2)
          g.setColor(90, 140, 140)
          g.polygon('fill', 0.0, -0.8, 0.25, 0.0, 0.0, 0.2)
          g.pop()
          g.print(body:getHP(), 0, 0)
        end
        g.pop()
      end
    end
  end

end

return MapView
