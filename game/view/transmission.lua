local vec2    = require 'cpml' .vec2
local COLORS  = require 'domain.definitions.colors'
local PLAYSFX = require 'helpers.playsfx'
local RANDOM = require 'common.random'

local Transmission = Class{
  __includes = { ELEMENT }
}

local _SPD = 40
local _COOLDOWN = 0.1
local _WIDTH = 8
local _MAX_OFFSET = 8
local _RADIUS = 12
local _COLOR_DISTORTION = 1.5
local _MIN_BEND_OFFSET = 5
local _MAX_BEND_OFFSET = 20
local _BEND_ANGLE = math.pi/5

function Transmission:init(origin, target, color, duration, bending_number)
  ELEMENT.init(self)
  self.target = target
  self.origin = origin
  self.start = origin:getPoint()
  self.finish = target:getPoint()
  self.width_scale = 1
  self.warmup = 0.05

  --Slight offset for transmisison
  self.ori_ox = RANDOM.safeGenerate(-_MAX_OFFSET, _MAX_OFFSET)
  self.ori_oy = RANDOM.safeGenerate(-_MAX_OFFSET, _MAX_OFFSET)
  self.tar_ox = RANDOM.safeGenerate(-_MAX_OFFSET, _MAX_OFFSET)
  self.tar_oy = RANDOM.safeGenerate(-_MAX_OFFSET, _MAX_OFFSET)

  --Create bendings
  self.bending_number = bending_number or 6
  self.bending_offsets = {}
  for i = 1, self.bending_number do
    self.bending_offsets[i] = RANDOM.safeGenerate(_MIN_BEND_OFFSET, _MAX_BEND_OFFSET)
  end
  self.bending_angles = {}
  for i = 1, self.bending_number do
    self.bending_angles[i] = RANDOM.safeGenerate(-_BEND_ANGLE, _BEND_ANGLE)
  end

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
  local ori = vec2(self.start.x + self.ori_ox, self.start.y + self.ori_oy)
  local tar = vec2(self.finish.x + self.tar_ox, self.finish.y + self.tar_oy)

  --Draw origin and target circle--
  g.setColor(self.color[1]*_COLOR_DISTORTION,
             self.color[2]*_COLOR_DISTORTION,
             self.color[3]*_COLOR_DISTORTION,
             self.color[4])
  g.circle("fill", ori.x, ori.y, _RADIUS * self.width_scale)
  g.circle("fill", tar.x, tar.y, _RADIUS * self.width_scale)

  --Draw line--
  g.setLineWidth(_WIDTH * self.width_scale)
  g.setColor(self.color)
  --Insert origin position
  local points = {ori.x, ori.y}
  --Insert bendings
  local norm = (tar-ori):normalize()
  local dist = ori:dist(tar)/(self.bending_number+1)
  local sign = 1
  for i = 1, self.bending_number do
    local off = self.bending_offsets[i]
    local angle = self.bending_angles[i]
    local pos = ori+norm*dist*i
    pos = pos + norm:perpendicular():rotate(angle)*off*sign
    table.insert(points,pos.x)
    table.insert(points,pos.y)
    sign = sign*-1
  end
  --Insert target position
  table.insert(points, tar.x)
  table.insert(points, tar.y)
  g.line(points)
end

return Transmission
