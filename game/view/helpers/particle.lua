
-- luacheck: globals love

local Class   = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"
local RES     = require 'resources'
local vec2    = require 'cpml' .vec2
local COLORS  = require 'domain.definitions.colors'

local Particles = Class{
  __includes = { ELEMENT }
}

function Particles:init(args)
  ELEMENT.init(self)
  local texture = args.texture or RES.loadTexture('pixel')
  self.particles = love.graphics.newParticleSystem(texture, args.max_number or 128)
  local lifetime = args.lifetime or .75
  self.particles:setParticleLifetime(lifetime)
  self.particles:setSizeVariation(args.size_variation or 0)
  self.particles:setLinearDamping(args.linear_damping or 6)
  self.particles:setSpeed(args.speed or 100)
  self.particles:setSpread(args.spread or 2*math.pi)
  self.particles:setColors(args.colors and unpack(args.colors) or unpack{COLORS.NEUTRAL, COLORS.TRANSP})
  self.particles:setSizes(args.sizes or 4)
  self.particles:setEmissionRate(args.emission_rate or 30)
  self.particles:setEmissionArea(args.emission_area and unpack(args.emission_area) or unpack{'ellipse', 0, 0, 0, false})
  self.particles:setTangentialAcceleration(args.tangential_acceleration or -512)
  self.pos = args.position or vec2()

  self.particles:emit(args.number or 48)
  self:register("HUD_FX")

  self:addTimer(nil, MAIN_TIMER, "after", lifetime,
      function()
        self:destroy()
      end)
  end
end

function Particles:update(dt)
  self.particles:update(dt)
end

function Particles:draw()
  local g = love.graphics
  g.setColor(1,1,1,1)
  g.draw(self.particles, self.pos.x, self.pos.y)
end

return Particles
