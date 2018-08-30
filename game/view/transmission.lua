
local vec2   = require 'cpml' .vec2
local COLORS = require 'domain.definitions.colors'

local Transmission = Class{
  __includes = { ELEMENT }
}

local _SPD = 40
local _COOLDOWN = 0.1
local _WIDTH = 8

function Transmission:init(origin, target)
  ELEMENT.init(self)
  self.target = target
  self.start = origin:clone()
  self.finish = self.target:getPoint()
  self.width_scale = 1
  self.warmup = 0.05
  self:addTimer("start", MAIN_TIMER, "tween", 0.5, self,
                { width_scale = 0 }, 'in-back',
                function () self:kill() end)
end

function Transmission:update(dt)
  self.warmup = math.max(self.warmup - dt, 0)
  self.finish = self.target:getPoint()
end

function Transmission:draw()
  if self.warmup > 0 then return end
  local g = love.graphics
  g.setLineWidth(_WIDTH * self.width_scale)
  g.setColor(COLORS.NEUTRAL)
  g.line(self.start.x, self.start.y, self.finish.x, self.finish.y)
end

return Transmission

