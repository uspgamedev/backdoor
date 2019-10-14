
-- luacheck: globals MAIN_TIMER

local DB        = require 'database'
local RES       = require 'resources'
local VIEWDEFS  = require 'view.definitions'
local Deferred  = require 'common.deferred'

local vec2      = require 'cpml'.vec2
local Class     = require "steaming.extra_libs.hump.class"
local ELEMENT   = require "steaming.classes.primitives.element"

local BodyView = Class {
  __includes = { ELEMENT }
}

function BodyView:init(body)
  ELEMENT.init(self)
  local idle_appearance = DB.loadSpec('appearance', body:getAppearance()).idle
  local i, j = body:getPos()
  self.sprite = RES.loadSprite(idle_appearance)
  self.body = body
  self.position = BodyView.tileToScreen(i, j)
end

function BodyView.tileToScreen(i, j)
  return vec2((j - 1) * VIEWDEFS.TILE_W, (i - 1) * VIEWDEFS.TILE_H)
end

function BodyView:setPosition(i, j)
  self.position = BodyView.tileToScreen(i, j)
end

function BodyView:moveTo(i, j, t, curve)
  curve = curve or 'out-cubic'
  local deferred = Deferred:new{}
  local target = BodyView.tileToScreen(i, j)
  assert(not self:getTimer("move_to", MAIN_TIMER))
  self:addTimer("move_to", MAIN_TIMER, "tween", t, self, { position = target },
                curve, function () deferred:trigger()
                                   self:removeTimer('move_to', MAIN_TIMER) end)
  return deferred
end

function BodyView:drawAtRow(row)
  local x = self.position.x
  local y = self.position.y - row * VIEWDEFS.TILE_H
  self.sprite:draw(x, y)
end

return BodyView

