
-- luacheck: globals love MAIN_TIMER

local RES     = require 'resources'
local Class   = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"
local COLORS  = require 'domain.definitions.colors'
local vec2    = require 'cpml' .vec2

local Sparkle = Class({ __includes = { ELEMENT } })

function Sparkle:init(origin, target)
  ELEMENT.init(self)
  self.particles = Sparkle._makeParticles()
  self.particles:start()
  self:register("HUD")
  self.position = origin
  self:addTimer(
    "dash_sparkles", MAIN_TIMER, "tween", 1, self, { position = target },
    'out-cubic',
    function ()
      self.particles:setEmissionRate(0)
      self.particles:setParticleLifetime(.5)
      self:addTimer("wait_sparkles", MAIN_TIMER, "after", 1,
                    function () self:destroy() end)
    end
  )
end

function Sparkle._makeParticles()
  local pixel = RES.loadTexture('pixel')
  local p = love.graphics.newParticleSystem(pixel, 256)
  p:reset()
  p:setTexture(pixel)
  p:setParticleLifetime(1)
  p:setEmissionRate(128)
  p:setSizes(4)
  p:setSizeVariation(1)
  p:setSpread(0)
  p:setSpeed(0, 0)
  p:setAreaSpread('normal', 8, 8)
  p:setLinearAcceleration(0, 0, 0, 0)
  p:setColors(COLORS.NEUTRAL, COLORS.TRANSP)
  p:setEmitterLifetime(-1)
  return p
end

function Sparkle:update(dt)
  self.particles:update(dt)
end

function Sparkle:draw()
  love.graphics.setColor(1,1,1)
  self.particles:setPosition(self.position:unpack())
  love.graphics.draw(self.particles, 0, 0)
end

return Sparkle

