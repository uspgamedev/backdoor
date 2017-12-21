
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
  local draw_sprite = sectorview:getBodySprite(body)
  sectorview:setBodySprite(
    body,
    function (x,y,r,sx,sy)
     local di, dj = unpack(offset)
     local dx, dy = dj*_TILE_W, di*_TILE_H
     x, y = x+dx, y+dy
     draw_sprite(x,y,r,sx,sy)
    end
  )
  sectorview:addTimer(
    nil, MAIN_TIMER, "tween", dist/20/args.speed_factor, offset, {0, 0},
    "in-out-quad",
    function()
      sectorview:setBodySprite(body, draw_sprite)
      sectorview:finishVFX()
    end
  )
end

return SPRITEFX

