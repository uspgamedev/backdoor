local TILE_W = 80
local TILE_H = 80

local Cursor

local MapView = Class{
  __includes = { ELEMENT }
}

function MapView:init(map)

  ELEMENT.init(self)

  self.map = map
  self.target = nil

  self.cursor = nil

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
    local i, j = self.target:getPos()
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
  local c_i, c_j = self:getCursorPos()
  --Draw Cursor, if it exists
  if self.cursor then
      local x, y = (c_j-1)*TILE_W, (c_i-1)*TILE_H
      g.push()
      g.translate(x, y)
      if self.cursor.valid_position_func(c_i,c_j) then
          g.setColor(250, 250, 250)
      else
          g.setColor(255,0,0)
      end
      local line_w = love.graphics.getLineWidth()
      love.graphics.setLineWidth(4)
      g.rectangle("line", 0, 0, TILE_W, TILE_H)
      love.graphics.setLineWidth(line_w)
      g.pop()
  end

end

--CURSOR FUNCTIONS

function MapView:newCursor(i,j,valid_position_func)
    i, j = i or 1, j or 1
    self.cursor = Cursor(i,j,valid_position_func)
end

function MapView:removeCursor()
    self.cursor = nil
end

function MapView:getCursorPos()
    if not self.cursor then return end

    return self.cursor:getPos()
end

function MapView:setCursorPos(i,j)
    if not self.cursor then return end

    self.cursor.i = i
    self.cursor.j = j
end

function MapView:moveCursor(di,dj)
    if not self.cursor then return end

    self.cursor.i = self.cursor.i + di
    self.cursor.j = self.cursor.j + dj
end

function MapView:lookAtCursor()
  if self.cursor then
    self:lookAt(self.cursor)
  end
end

--CURSOR CLASS--

Cursor = Class{
  __includes = { ELEMENT }
}

function Cursor:init(i, j, valid_position_func)
    self.i = i
    self.j = j

    self.valid_position_func = valid_position_func
end

function Cursor:getPos()
    return self.i, self.j
end

return MapView
