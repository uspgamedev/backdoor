
local Camera = require "steaming.extra_libs.hump.camera"
local math = require 'common.math'


local _width, _height = love.graphics.getDimensions()
local CAM = Camera(_width/2, _height/2, 1, 0, Camera.smooth.damped(5))

function CAM:attach(x, y, w, h, noclip)
  local g = love.graphics
  x,y = x or 0, y or 0
  w,h = w or g.getWidth(), h or g.getHeight()

  self._sx,self._sy,self._sw,self._sh = g.getScissor()
  if not noclip then
    g.setScissor(x,y,w,h)
  end

  local cx,cy = x+w/2, y+h/2
  g.push()
  g.translate(math.round(cx), math.round(cy))
  g.scale(self.scale)
  g.rotate(self.rot)
  g.translate(-math.round(self.x*self.scale)/self.scale,
              -math.round(self.y*self.scale)/self.scale)
end

return CAM

