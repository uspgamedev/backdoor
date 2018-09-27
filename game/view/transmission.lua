
local vec2    = require 'cpml' .vec2
local COLORS  = require 'domain.definitions.colors'
local PLAYSFX = require 'helpers.playsfx'

local Transmission = Class{
  __includes = { ELEMENT }
}

local _SPD = 40
local _COOLDOWN = 0.1
local _WIDTH = 8

function Transmission:init(origin, target, color, duration)
  ELEMENT.init(self)
  self.target = target
  self.origin = origin
  self.start = origin:getPoint()
  self.finish = target:getPoint()
  self.width_scale = 1
  self.warmup = 0.05
  self.color = color or COLORS.NEUTRAL
  self:addTimer("start", MAIN_TIMER, "tween", duration or 0.5, self,
                { width_scale = 0 }, 'in-back',
                function () self:kill() end)
  PLAYSFX 'transmission'
end

function Transmission:update(dt)
  self.warmup = math.max(self.warmup - dt, 0)
  self.start = self.origin:getPoint()
  self.finish = self.target:getPoint()
end

function Transmission:draw()
  if self.warmup > 0 then return end
  local g = love.graphics
  g.setLineWidth(_WIDTH * self.width_scale)
  g.setColor(self.color)
  g.line(self.start.x, self.start.y, self.finish.x, self.finish.y)
end

return Transmission

