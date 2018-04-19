
local VIEWDEFS  = require 'view.definitions'
local SPRITEFX  = {}

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H

function SPRITEFX.apply(sectorview, args)
  local body, i, j = args.body, unpack(args.origin)
  local i0, j0 = body:getPos()
  local offset = {i - i0, j - j0}
  local di, dj = unpack(offset)
  local dist   = (di*di + dj*dj)^0.5
  local body_sprite = sectorview:getBodySprite(body)
  local current_observer = sectorview:getTarget()
  if current_observer and current_observer.fov then
    local fov = current_observer:getFov()
    if (not fov[i0][j0] or fov[i0][j0] == 0) and
       (not fov[i][j] or fov[i][j] == 0) then
      return sectorview:finishVFX()
    end
  end
  body_sprite:setDecorator(
    function (self, x, y, ...)
      local di, dj = unpack(offset)
      local dx, dy = dj*_TILE_W, di*_TILE_H
      x, y = x+dx, y+dy
      body_sprite:render(x, y, ...)
    end
  )
  sectorview:addTimer(
    nil, MAIN_TIMER, "tween", dist/20/args.speed_factor, offset, {0, 0},
    "in-out-quad",
    function()
      body_sprite:clearDecorator()
      sectorview:finishVFX()
    end
  )
end

return SPRITEFX

