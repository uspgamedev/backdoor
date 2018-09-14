
local DB      = require 'database'
local RES     = require 'resources'
local FONT    = require 'view.helpers.font'
local DEFS    = require 'view.definitions'
local PROFILE = require 'infra.profile'
local Color   = require 'common.color'
local Timer   = require 'steaming.extra_libs.hump.timer'

local PlayerDeathView = Class({ __includes = ELEMENT })

function PlayerDeathView:init(playeractor)
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
  self.pos = {x, y}
  self.color = Color:new({1, 1, 1, 1})
  self.volume = 0
  self.out = 0
  self.done = false
  self.timer = Timer:new()
  self.timer:script(function(wait)
    wait(0.5)
    noise:setVolume(0)
    noise:play()
    self.timer:during(6, function()
      self.pos[1] = x + (math.random() * offset - offset/2)
      noise:setVolume(self.volume)
    end)
    self.timer:tween(5, self.pos, {[2] = y + 32}, "linear")
    self.timer:tween(2, self.color, {1, 0.2, 0.1, 0.8}, "in-out-quad")
    self.timer:tween(2, self, { volume = max_volume }, "linear")
    wait(3)
    self.timer:tween(2, self, { volume = 0 }, "linear", function()
      noise:stop()
    end)
    self.timer:tween(2, self.color, {1, 0.4, 0.2, 0}, "in-out-quad")
    wait(2)
    self.timer:tween(2, self, { out = 1 }, "linear", function()
      self.done = true
    end)
  end)
end

function PlayerDeathView:update(dt)
  self.timer:update(dt)
end

function PlayerDeathView:isDone()
  return self.done
end

function PlayerDeathView:draw()
  local g = love.graphics
  local x, y = unpack(self.pos)
  local w, h = g.getDimensions()
  g.setColor({ 0, 0, 0, 1 })
  g.rectangle("fill", 0, 0, w, h)
  g.setColor(self.color)
  self.sprite:draw(x-DEFS.TILE_W/2, y)
  FONT.set("Text", 32)
  g.setColor(1, 1, 1, 1 - self.out)
  g.printf("YOU DIED", 0, h / 2 - 144, w, "center")
  g.setColor(0, 0, 0, self.out)
  g.rectangle("fill", 0, 0, w, h)
end

return PlayerDeathView

