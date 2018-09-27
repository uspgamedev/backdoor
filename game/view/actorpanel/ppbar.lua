
local COLORS = require 'domain.definitions.colors'
local FONT = require 'view.helpers.font'
local DEFS = require 'domain.definitions'
local Node = require 'view.node'
local math = require 'common.math'

local PPBar = Class({ __includes = { Node } })

local _WIDTH = 256
local _FMT = "%s %d/%d"

function PPBar:init(actor, x, y)
  Node.init(self)
  self:setPosition(x, y)
  self.actor = actor
  self.progress = 0
  self.label = "PP"
  self.fullcolor = COLORS.PP
  self.emptycolor = COLORS.PP
  self.absolute_max = DEFS.MAX_PP
end

function PPBar:process(dt)
  local actor = self.actor
  local difference = actor:getPP() / self.absolute_max - self.progress
  self.progress = self.progress + difference / 2
end

function PPBar:render(g)
  local progress = self.progress
  g.push()
  g.setColor(COLORS.EMPTY)
  g.rectangle("fill", 0, 0, _WIDTH, 12)
  g.translate(-1, -1)
  g.setColor(self.fullcolor * progress + (1 - progress) * self.emptycolor)
  g.rectangle("fill", 0, 0, _WIDTH * self.progress, 12)
  -- text
  FONT.set("Text", 20)
  local text = _FMT:format(self.label,
                           math.round(self.progress * self.absolute_max),
                           self.absolute_max)
  g.translate(8, -16)
  g.setColor(COLORS.BLACK)
  g.printf(text, 0, 0, _WIDTH, "left")
  g.translate(-2, -2)
  g.setColor(COLORS.NEUTRAL)
  g.printf(text, 0, 0, _WIDTH, "left")
  return g.pop()
end

return PPBar

