
local COLORS = require 'domain.definitions.colors'
local FONT = require 'view.helpers.font'
local PPBar = require 'view.actorpanel.ppbar'

local LifeBar = Class({ __includes = { PPBar } })

function LifeBar:init(actor, x, y)
  PPBar.init(self, actor, x, y)
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

