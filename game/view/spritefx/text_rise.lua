
-- luacheck: globals love MAIN_TIMER

local VIEWDEFS  = require 'view.definitions'
local FONT      = require 'view.helpers.font'
local COLORS    = require 'domain.definitions.colors'
local Color     = require 'common.color'
local Sparkle   = require 'view.gameplay.actionhud.fx.sparkle'
local Util      = require 'steaming.util'
local vec2      = require 'cpml' .vec2
local SPRITEFX  = {}

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H

local _NUMBER_COLOR = {
  ['blocked-damage'] = 'NOTIFICATION',
  damage = 'NOTIFICATION',
  heal = 'SUCCESS',
  food = 'PP',
  focus = 'FOCUS',
  status = 'WARNING'
}

local _SIGNALS = {
  ['blocked-damage'] = '↓-',
  damage = '-',
  heal = '+',
  focus = '+',
  food = '+',
}

local _font

function SPRITEFX.apply(sectorview, args)
  local body, amount = args.body, args.amount
  local text_type = args.text_type
  local signal = _SIGNALS[text_type]
  local body_view = sectorview:getBodyView(body)
  local body_sprite = body_view.sprite
  local animation_info = { y = 0, a = 0.5}
  local text
  if args.string then
    text = args.string
  else
    text = ("%s%d"):format(signal, amount)
  end
  _font = _font or FONT.get('Text', 32)
  if text_type == 'food' then
    local fbuffer = Util.findId('frontbuffer_view')
    local route = body:getSector():getRoute()
    local controlled_actor = route.getControlledActor()
    local controlled_body = controlled_actor:getBody()
    if body == controlled_body then
      local camera_pos = vec2(VIEWDEFS.VIEWPORT_DIMENSIONS()) / 2
      Sparkle():go(camera_pos, fbuffer:getCenter())
               :andThen(function()
                 fbuffer.ppcounter:setPP(controlled_actor:getPP())
               end)
    end
  end
  body_sprite:setDecorator(
    function (_, x, y, ...)
      local g = love.graphics
      body_sprite:render(x, y, ...)
      x = x + _TILE_W/2 - _font:getWidth(text)/2
      y = y - _TILE_H/2 - animation_info.y
      _font:set()
      local transparency = COLORS.NEUTRAL
                         * Color:new {1, 1, 1, animation_info.a}
      g.setColor(COLORS.DARK * transparency)
      g.print(text, x + 2, y + 2)
      g.setColor(COLORS[_NUMBER_COLOR[text_type]] * transparency)
      g.print(text, x, y)
    end
  )
  sectorview:addTimer(nil, MAIN_TIMER, "tween", 0.2,
                      animation_info, { y = 96, a = 1 }, "out-cubic",
                      function()
                        sectorview:addTimer(nil, MAIN_TIMER, "after", 0.3,
                                            function ()
                                              body_sprite:clearDecorator()
                                              sectorview:finishVFX()
                                            end)
                      end)
end

return SPRITEFX
