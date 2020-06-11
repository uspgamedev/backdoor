
local RES     = require 'resources'

local Class   = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"

local AnimationFX = Class {
  __includes = { ELEMENT }
}

function AnimationFX:init(sprite_name, position, layer)
  ELEMENT.init(self)
  self.position = position
  self.sprite = RES.loadSprite(sprite_name)
  self:register(layer or "HUD_FX")
end

function AnimationFX:update(_)
  if self.sprite:isAnimationFinished() then
    self:kill()
  end
end

function AnimationFX:draw()
  local g = love.graphics -- luacheck: globals love
  g.setColor(1, 1, 1, 1)
  self.sprite:draw(self.position:unpack())
end

return AnimationFX

