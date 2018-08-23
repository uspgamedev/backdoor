
local vec2   = require 'cpml' .vec2
local COLORS = require 'domain.definitions.colors'

local Transmission = Class{
  __includes = { ELEMENT }
}

local _SPD = 40
local _COOLDOWN = 0.1

function Transmission:init(origin, target)
  ELEMENT.init(self)
  self.target = target
  self.start = origin:clone()
  self.finish = origin:clone()
  self.cooldown = 0
  self.state = 'expanding'
  self.warmup = 0.05
end

function Transmission:update(dt)
  self.warmup = math.max(self.warmup - dt, 0)
  local targetpos = self.target:getPoint()
  if self.state == 'expanding' then
    self.finish = self.finish + (targetpos - self.finish) * dt * _SPD
    if (self.finish - targetpos):len() < 2 then
      self.finish = targetpos
      self.state = 'cooldown'
    end
  elseif self.state == 'cooldown' then
    self.cooldown = self.cooldown + dt
    if self.cooldown >= _COOLDOWN then
      self.state = 'contracting'
    end
  elseif self.state == 'contracting' then
    self.start = self.start + (targetpos - self.start) * dt * _SPD
    if (self.start - targetpos):len() < 2 then
      self.start = targetpos
      self:kill()
    end
  end
end

function Transmission:draw()
  if self.warmup > 0 then return end
  local g = love.graphics
  g.setLineWidth(4)
  g.setColor(COLORS.NEUTRAL)
  g.line(self.start.x, self.start.y, self.finish.x, self.finish.y)
end

return Transmission

