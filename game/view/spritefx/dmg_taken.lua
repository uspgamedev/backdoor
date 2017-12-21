
local VIEWDEFS  = require 'view.definitions'
local FONT      = require 'view.helpers.font'
local SPRITEFX  = {}

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H

function SPRITEFX.apply(sectorview, args)
  local body, amount = args.body, args.amount
  local i, j = body:getPos()
  local draw_sprite = sectorview:getBodySprite(body)
  local font = FONT.get('Text', 24)
  local dmg_offset = {0}
  sectorview:setBodySprite(
    body,
    function (x,y,r,sx,sy)
      draw_sprite(x,y,r,sx,sy)
      font:set()
      love.graphics.printf(("-%d"):format(amount), x,
                           y - _TILE_H/2 - dmg_offset[1],
                           _TILE_W, 'center')
    end
  )
  sectorview:addTimer(
    nil, MAIN_TIMER, "tween", 0.2, dmg_offset, {100},
    "out-back",
    function()
      sectorview:addTimer(
        nil, MAIN_TIMER, "after", 0.5, function ()
          sectorview:setBodySprite(body, draw_sprite)
          sectorview:finishVFX()
        end
      )
    end
  )
end

return SPRITEFX

