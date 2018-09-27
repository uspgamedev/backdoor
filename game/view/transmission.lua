
local vec2    = require 'cpml' .vec2
local COLORS  = require 'domain.definitions.colors'
local PLAYSFX = require 'helpers.playsfx'

local Transmission = Class{
  __includes = { ELEMENT }
}

local _SPD = 40
local _COOLDOWN = 0.1
local _WIDTH = 8
local _MAX_OFFSET = 9
local _RADIUS = 12
local _COLOR_DISTORTION = 1.8

function Transmission:init(origin, target, color, duration)
  ELEMENT.init(self)
  self.target = target
  self.origin = origin
  self.start = origin:getPoint()
  self.finish = target:getPoint()
  self.width_scale = 1
  self.warmup = 0.05

  --Slight offset for transmisison
  self.ori_ox = love.math.random(-_MAX_OFFSET, _MAX_OFFSET)
  self.ori_oy = love.math.random(-_MAX_OFFSET, _MAX_OFFSET)
  self.tar_ox = love.math.random(-_MAX_OFFSET, _MAX_OFFSET)
  self.tar_oy = love.math.random(-_MAX_OFFSET, _MAX_OFFSET)


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
  local ori_x = self.start.x + self.ori_ox
  local ori_y = self.start.y + self.ori_oy
  local tar_x = self.finish.x + self.tar_ox
  local tar_y = self.finish.y + self.tar_oy

  --Draw origin and target circle
  g.setColor(self.color[1]*_COLOR_DISTORTION,
             self.color[2]*_COLOR_DISTORTION,
             self.color[3]*_COLOR_DISTORTION,
             self.color[4])
  g.circle("fill", ori_x, ori_y, _RADIUS * self.width_scale)
  g.circle("fill", tar_x, tar_y, _RADIUS * self.width_scale)

  --Draw line
  g.setLineWidth(_WIDTH * self.width_scale)
  g.setColor(self.color)
  g.line(ori_x, ori_y, tar_x, tar_y)
end

return Transmission
