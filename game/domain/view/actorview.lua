
local DB = require 'database'
local COLORS = require 'domain.definitions.colors'

local ActorView = Class{
  __includes = { ELEMENT }
}

local _initialized = false
local _exptext, _statstext, _depthtext
local WIDTH, HEIGHT, FONT

local function _initGraphicValues()
  WIDTH, HEIGHT = love.graphics.getDimensions()
  FONT = love.graphics.newFont(DB.loadFontPath("Saira"), 24)
  FONT:setLineHeight(1)
  _exptext = "EXP: %d"
  _statstext = "STATS\nATH: %d\nARC: %d\nMEC: %d"
  _depthtext = "DEPTH: %d"
  _initialized = true
end

function ActorView:init(route)

  ELEMENT.init(self)

  self.route = route

  if not _initialized then _initGraphicValues() end

end

function ActorView:draw()
  local g = love.graphics
  local actor = self.route.getControlledActor()
  local ath = actor:getATH()
  local arc = actor:getARC()
  local mec = actor:getMEC()
  local sector = self.route.getCurrentSector()

  g.push()

  g.setFont(FONT)
  g.setColor(COLORS.NEUTRAL)

  g.translate(40, 40)
  g.print(_exptext:format(actor:getExp()), 0, 0)

  g.translate(0, 1.5*FONT:getHeight())
  g.print(_statstext:format(ath, arc, mec))

  g.pop()

  g.push()

  local str = _depthtext:format(sector:getDepth())
  local w = FONT:getWidth(str)
  g.translate(WIDTH - 40 - w, 40)
  g.printf(str, 0, 0, w, "right")

  g.pop()
end

return ActorView

