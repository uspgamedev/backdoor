
local COLORS  = require 'domain.definitions.colors'
local FONT    = require 'view.helpers.font'
local Class   = require "steaming.extra_libs.hump.class"
local Node   = require 'view.node'

local LifeBar = Class({ __includes = { Node } })

function LifeBar:init(actor, x, y)
  Node.init(self)
  self:setPosition(x, y)
  self.actor = actor
  self.progress = 0
  self.label = "HP"
  self.fullcolor = COLORS.SUCCESS
  self.emptycolor = COLORS.NOTIFICATION
  self.absolute_max = actor:getBody():getMaxHP()
end

function LifeBar:process(dt)
  local body = self.actor:getBody()
  local max = body:getMaxHP()
  local difference = body:getHP() / max - self.progress
  self.progress = self.progress + difference / 2
  self.absolute_max = max
end

return LifeBar
