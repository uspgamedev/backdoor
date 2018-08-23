
local vec2   = require 'cpml' .vec2
local COLORS = require 'domain.definitions.colors'

local Transmission = Class{
  __includes = { ELEMENT }
}

local _SPD = 10
local _COOLDOWN = 0.5

function Transmission:init(origin, target)
  ELEMENT.init(self)
  self.origin = origin
  self.target = target
  self.start = origin
  self.finish = origin
  self.cooldown = 0
  self.state = 'expanding'
end

function Transmission:update(dt)
  if self.state == 'expanding' then
    self.finish = self.finish + (self.target - self.finish) * dt * _SPD
    if (self.finish - self.target):len() < 2 then
      self.finish = self.target
      self.state = 'cooldown'
    end
  elseif self.state == 'cooldown' then
    self.cooldown = self.cooldown + dt
    if self.cooldown >= _COOLDOWN then
      self.state = 'contracting'
    end
  elseif self.state == 'contracting' then
    self.start = self.start + (self.target - self.start) * dt * _SPD
    if (self.start - self.target):len() < 2 then
      self.start = self.target
      self:kill()
    end
  end
end

function Transmission:draw()
  local g = love.graphics
  g.setLineWidth(4)
  g.setColor(COLORS.NEUTRAL)
  g.line(self.start.x, self.start.y, self.finish.x, self.finish.y)
end

return Transmission

