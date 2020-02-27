
local DB      = require 'database'
local RES     = require 'resources'
local FONT    = require 'view.helpers.font'
local DEFS    = require 'view.definitions'
local PROFILE = require 'infra.profile'
local Color   = require 'common.color'
local Timer   = require 'steaming.extra_libs.hump.timer'
local Class   = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"

local PlayerWinView = Class({ __includes = ELEMENT })

function PlayerWinView:init(playeractor)
  ELEMENT.init(self)
  local w, h = love.graphics.getDimensions()
  local x, y = w/2, h/2
  local offset = 8
  local appearance = DB.loadSpec(
    'appearance', playeractor:getBody():getAppearance()
  )
  local noise = RES.loadSFX("death-crumble")
  local max_volume = PROFILE.getPreference("sfx-volume") / 100
  noise:setLooping(true)
  self.camera = require 'common.camera'
  self.sprite = RES.loadSprite(appearance.idle)
  self.sprite_w = self.sprite:getWidth()
  self.initial_x = x
  self.pos = {x, y}
  self.color = Color:new({1, 1, 1, 1})
  self.volume = 0
  self.scale = 1
  self.spinning_speed = 1
  self.out = 0
  self.done = false
  self.timer = Timer:new()
  self.timer:script(function(wait)
    wait(0.5)
    noise:setVolume(0)
    noise:play()
    self.timer:during(6, function()
      noise:setVolume(self.volume)
      self.sprite:setScale(self.scale)
      local w = self.sprite:getDimensions()
      self.pos[1] = self.initial_x + (1 - self.scale)*self.sprite_w/2
    end)
    self:rotatePlayer()
    self.timer:tween(5, self, {spinning_speed = 8}, "in-quad")
    self.timer:tween(5, self.pos, {[2] = y - 120}, "linear")
    self.timer:tween(3, self.color, {0.6, 0.6, 1, 0.9}, "in-out-quad")
    self.timer:tween(2, self, { volume = max_volume }, "linear")
    wait(3)
    self.timer:tween(2, self, { volume = 0 }, "linear", function()
      noise:stopAll()
    end)
    self.timer:tween(3, self.color, {0, 0, 1, 0}, "in-out-quad")
    wait(3)
    self.timer:tween(2, self, { out = 1 }, "linear", function()
      self.done = true
    end)
  end)
end

function PlayerWinView:update(dt)
  self.timer:update(dt)
end

function PlayerWinView:isDone()
  return self.done
end

function PlayerWinView:rotatePlayer()
  local time = 1/self.spinning_speed
  if self:isDone() then return end
  if self.scale == 1 then
    self.timer:tween(time, self, {scale = -1}, "linear",
    function()
      self.scale = -1
      self:rotatePlayer()
    end)
  elseif self.scale == -1 then
    self.timer:tween(time, self, {scale = 1}, "linear",
    function()
      self.scale = 1
      self:rotatePlayer()
    end)
  end
end

function PlayerWinView:draw()
  local g = love.graphics
  local x, y = unpack(self.pos)
  local w, h = g.getDimensions()
  g.setColor({ 0, 0, 0, 1 })
  g.rectangle("fill", 0, 0, w, h)
  g.setColor(self.color)
  g.push()
  self.sprite:draw(x-DEFS.TILE_W/2, y)
  g.pop()
  FONT.set("Text", 32)
  g.setColor(1, 1, 1, 1 - self.out)
  g.printf("YOU WON!", 0, 120, w, "center")
  g.setColor(0, 0, 0, self.out)
  g.rectangle("fill", 0, 0, w, h)
end

return PlayerWinView
