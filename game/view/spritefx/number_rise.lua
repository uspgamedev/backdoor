
local VIEWDEFS  = require 'view.definitions'
local FONT      = require 'view.helpers.font'
local COLORS    = require 'domain.definitions.colors'
local Color     = require 'common.color'
local SPRITEFX  = {}

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H

local _NUMBER_COLOR = {
  damage = 'NOTIFICATION',
  heal = 'SUCCESS',
  food = 'WARNING',
}

local _SIGNALS = {
  damage = '-',
  heal = '+',
  food = '+',
}

function SPRITEFX.apply(sectorview, args)
  local body, amount = args.body, args.amount
  local number_type = args.number_type
  local signal = _SIGNALS[number_type]
  local i, j = body:getPos()
  local body_sprite = sectorview:getBodySprite(body)
  local animation_info = { y = 0, a = 0.5}
  local number_text = ("%s%d"):format(signal, amount)
  _font = _font or FONT.get('Text', 32)
  body_sprite:setDecorator(
    function (self, x, y, ...)
      local g = love.graphics
      body_sprite:render(x, y, ...)
      y = y - _TILE_H/2 - animation_info.y
      _font:set()
      local transparency = COLORS.NEUTRAL
                         * Color:new {1, 1, 1, animation_info.a}
      g.setColor(COLORS.DARK * transparency)
      g.printf(number_text, x + 2, y + 2,
               _TILE_W, 'center')
      g.setColor(COLORS[_NUMBER_COLOR[number_type]] * transparency)
      g.printf(number_text, x, y,
               _TILE_W, 'center')
    end
  )
  sectorview:addTimer(nil, MAIN_TIMER, "tween", 0.2,
                      animation_info, { y = 96, a = 1 }, "out-cubic",
                      function()
                        sectorview:addTimer(nil, MAIN_TIMER, "after", 0.1,
                                            function ()
                                              body_sprite:clearDecorator()
                                              sectorview:finishVFX()
                                            end)
                      end)
end

return SPRITEFX

