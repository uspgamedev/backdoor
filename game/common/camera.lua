
local math     = require 'common.math'
local Camera   = require "steaming.extra_libs.hump.camera"
local VIEWDEFS = require 'view.definitions'

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H
local _HALF_W = VIEWDEFS.HALF_W
local _HALF_H = VIEWDEFS.HALF_H

local CAM = Camera(love.graphics.getWidth() / 2,
                   love.graphics.getHeight() / 2,
                   1, 0, Camera.smooth.damped(5))

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

function CAM:isTileInFrame(i, j)
  local cx, cy = CAM:position()
  cx = cx / _TILE_W
  cy = cy / _TILE_H
  return     j >= cx - _HALF_W
         and j <= cx + _HALF_W
         and i >= cy - _HALF_H
         and i <= cy + _HALF_H
end

return CAM

