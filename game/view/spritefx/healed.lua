
local VIEWDEFS  = require 'view.definitions'
local FONT      = require 'view.helpers.font'
local COLORS    = require 'domain.definitions.colors'
local SPRITEFX  = {}

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H

function SPRITEFX.apply(sectorview, args)
  local body, amount = args.body, args.amount
  local i, j = body:getPos()
  local body_sprite = sectorview:getBodySprite(body)
  local font = FONT.get('Text', 24)
  local dmg_offset = {0}
  body_sprite:setDecorator(
    function (self, x, y, ...)
      local g = love.graphics
      body_sprite:render(x, y, ...)
      font:set()
      g.setColor(COLORS.DARK)
      g.printf(("+%d"):format(amount), x + 2,
                           y - _TILE_H/2 - dmg_offset[1] + 2,
                           _TILE_W, 'center')
      g.setColor(COLORS.VALID)
      g.printf(("+%d"):format(amount), x,
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
          body_sprite:clearDecorator()
          sectorview:finishVFX()
        end
      )
    end
  )
end

return SPRITEFX

