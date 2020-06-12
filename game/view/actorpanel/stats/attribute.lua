
-- luacheck: globals love

local RES     = require 'resources'
local APT     = require 'domain.definitions.aptitude'
local COLORS  = require 'domain.definitions.colors'
local PLAYSFX = require 'helpers.playsfx'
local RANDOM  = require 'common.random'
local Node    = require 'view.node'
local Text    = require 'view.helpers.text'
local Class   = require "steaming.extra_libs.hump.class"

local abs  = math.abs
local min  = math.min
local max  = math.max
local pi   = math.pi

local function _newParticleSource()
  local pixel = RES.loadTexture('pixel')
  local particles = love.graphics.newParticleSystem(pixel, 128)
  particles:setParticleLifetime(.75)
  particles:setSizeVariation(0)
  particles:setLinearDamping(6)
  particles:setSpeed(256)
  particles:setSpread(2*pi)
  particles:setColors(COLORS.NEUTRAL, COLORS.TRANSP)
  particles:setSizes(4)
  particles:setEmissionArea('ellipse', 0, 0, 0, false)
  particles:setTangentialAcceleration(-512)
  return particles
end

local Attribute = Class({ __includes = { Node } })

function Attribute:init(actor, attribute_name, x, y, width)
  Node.init(self)
  self.actor = actor
  self.level = actor:getAttrLevel(attribute_name)
  self.percent = 0
  self.attribute_name = attribute_name:upper()
  self.attribute_text = Text('---', 'Text', 20)
  self.width = width
  self.rise = false
  self.particles = _newParticleSource()
  self:setPosition(x, y)
end

function Attribute:process(dt)
  -- freeze animations when rising level
  if self.rise then
    self.rise = self.rise - dt
    if self.rise <= 0 then self.rise = false end
  else
    -- update bar progress
    local upgrade = self.actor:getAttrUpgrade(self.attribute_name)
    local aptitude = self.actor:getAptitude(self.attribute_name)
    local level = self.level
    local total_prev = APT.CUMULATIVE_REQUIRED_ATTR_UPGRADE(aptitude, level)
    local total_next = APT.CUMULATIVE_REQUIRED_ATTR_UPGRADE(aptitude, level+1)

    local target = min(1, max(0, (upgrade - total_prev) /
                                 (total_next - total_prev)))
    self.percent = min(1, max(0, self.percent +
                                 8 * (target - self.percent) * dt))

    if abs(target - self.percent) < 0.01 then
      self.percent = target
    end

    -- check if level up
    local new_level = self.actor:getAttrLevel(self.attribute_name)
    local offset = new_level - self.level
    local step = offset / abs(offset)
    if new_level ~= self.level and self.percent == 1 then
      self.level = self.level + step
      self.percent = 0
      self.particles:emit(48)
      PLAYSFX('get-item', .1)
      self.rise = 0.5 -- this stops the update for that many seconds
    end
  end

  local diff = self.actor:getAttribute(self.attribute_name)
             - self.actor:getAttrLevel(self.attribute_name)
  local color = (diff > 0 and {0, 0.7, 1}) or
                (diff < 0 and {1, 0.8, 0.2}) or
                COLORS.NEUTRAL
  self.attribute_text:setText{
    COLORS.NEUTRAL,
    ("%s: "):format(self.attribute_name),
    self.rise and COLORS.NEUTRAL or color,
    ("%02d"):format(self.level)
  }
  self.particles:update(dt)
end

function Attribute:render(g)
  local bar_height = 16
  g.push()
  if self.rise then
    local rand = RANDOM.safeGenerate
    g.translate(2*(rand()*2-1), 2*(rand()*2-1))
  end
  g.setColor(COLORS.NEUTRAL)
  self.attribute_text:draw(0, 0)
  g.translate(0, 32)
  if not self.rise then
    g.setColor(COLORS.EMPTY)
  end
  g.rectangle("fill", 0, 0, self.width, bar_height)
  if not self.rise then
    g.setColor(COLORS[self.attribute_name])
  end
  g.rectangle("fill", 0, 0, self.percent*self.width, bar_height)
  g.setColor(COLORS.NEUTRAL)
  g.draw(self.particles, self.width, bar_height/2)
  g.pop()
end

return Attribute
