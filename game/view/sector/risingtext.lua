
local VIEWDEFS  = require 'view.definitions'
local Text      = require 'view.helpers.text'

local Deferred  = require 'common.deferred'

local Class     = require "steaming.extra_libs.hump.class"
local ELEMENT   = require "steaming.classes.primitives.element"

local _MAIN_TIMER = MAIN_TIMER -- luacheck: globals MAIN_TIMER
local _TILE_H = VIEWDEFS.TILE_H

local RisingText = Class {
  __includes = { ELEMENT }
}

function RisingText:init(bodyview, text, color)
  ELEMENT.init(self)

  self.text = Text(text, 'Text', 32, { color = color, dropshadow = true })
  self.bodyview = bodyview
  self.animation_info = { y = 0, a = 0.5 }

  self:register("HUD")
end

function RisingText:play()
  local deferred = Deferred:new{}
  self:addTimer(
    nil, _MAIN_TIMER, "tween", 0.2, self.animation_info, { y = 96, a = 1 },
    "out-cubic",
    function()
      self:addTimer(
        nil, _MAIN_TIMER, "after", 0.8,
        function ()
          deferred:trigger()
          self:kill()
        end
      )
    end
  )
  return deferred
end

function RisingText:draw()
  local x, y = self.bodyview:getScreenPosition():unpack()
  local w, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
  x = x - self.text:getTextWidth()/2 + w/2
  y = y - _TILE_H/2 - self.animation_info.y + h/2
  self.text:setAlpha(self.animation_info.a)
  self.text:draw(x, y)
end

return RisingText

