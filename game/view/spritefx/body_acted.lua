
local VIEWDEFS  = require 'view.definitions'
local SPRITEFX  = {}

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H

function SPRITEFX.apply(sectorview, args)
  local body = args.body
  local t = {0}
  local body_sprite = sectorview:getBodyView(body).sprite
  body_sprite:setDecorator(
    function (self, x, y, ...)
      local s = (t[1] - 0.5)*2
      body_sprite:render(x + _TILE_W/4*s, y, ...)
    end
  )
  sectorview:addTimer(
    nil, MAIN_TIMER, "tween", 0.1, t, {1},
    "in-linear",
    function()
      body_sprite:clearDecorator()
      sectorview:finishVFX()
    end
  )
end

return SPRITEFX

