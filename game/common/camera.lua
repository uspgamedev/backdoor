
-- luacheck: globals love

local math     = require 'common.math'
local vec2     = require 'cpml' .vec2
local Camera   = require "steaming.extra_libs.hump.camera"
local VIEWDEFS = require 'view.definitions'

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H
local _HALF_W = VIEWDEFS.HALF_W
local _HALF_H = VIEWDEFS.HALF_H

local function custom_damped_smoother(stiffness)
	assert(type(stiffness) == "number", "Invalid parameter: stiffness = "..tostring(stiffness))
	return function(dx,dy, s)
		local dts = love.timer.getDelta() * (s or stiffness)
    dts = math.min(dts, 1.0)
		return dx*dts, dy*dts
	end
end

local CAM = Camera(love.graphics.getWidth() / 2,
                   love.graphics.getHeight() / 2,
                   1, 0, custom_damped_smoother(5))

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
  local cx, cy = self:position()
  cx = cx / _TILE_W
  cy = cy / _TILE_H
  return     j >= cx - _HALF_W
         and j <= cx + _HALF_W
         and i >= cy - _HALF_H
         and i <= cy + _HALF_H
end

function CAM:relativeTileToScreen(i, j) -- luacheck: no self
  j = _HALF_W + j - 1
  i = _HALF_H + i - 1
  local x = (j - 0.5) * _TILE_W
  local y = (i - 0.5) * _TILE_H
  return vec2(x, y)
end

function CAM:getRangeBounds()
  local cx, cy = self:position() -- start point
  local rx, ry
  cx = math.floor(cx / _TILE_W - _HALF_W)
  cy = math.floor(cy / _TILE_H - _HALF_H)
  rx = math.ceil(cx + 2 * _HALF_W)
  ry = math.ceil(cy + 2 * _HALF_H)
  return { left = cx, right = rx, top = cy, bottom = ry }
end

function CAM:tilesInRange()
  local cx, cy = self:position() -- start point
  local rx, ry
  cx = math.floor(cx / _TILE_W - _HALF_W)
  cy = math.floor(cy / _TILE_H - _HALF_H)
  rx = math.ceil(cx + 2 * _HALF_W)
  ry = math.ceil(cy + 2 * _HALF_H)
  local init_s = { cy, cx - 1 }
  return function(s)
    s[2] = s[2] + 1

    -- advance line
    if s[2] > rx then
      s[2] = cx
      s[1] = s[1] + 1
      -- check for end of lines
      if s[1] > ry then return end
    end

    return s[1], s[2]
  end, init_s
end

return CAM

