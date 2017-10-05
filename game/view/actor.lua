
local RES = require 'resources'
local FONT = require 'view.helpers.font'
local COLORS = require 'domain.definitions.colors'

local ActorView = Class{
  __includes = { ELEMENT }
}

local _initialized = false
local _exptext, _statstext, _depthtext
local _width, _height, _font


local function _initGraphicValues()
  _width, _height = love.graphics.getDimensions()
  _font = FONT.get("Text", 24)
  _font:setLineHeight(1)
  _exptext = "EXP: %d"
  _statstext = "STATS\nATH: %d\nARC: %d\nMEC: %d"
  _depthtext = "DEPTH: %d"
  _initialized = true
end

function ActorView:init(route)

  ELEMENT.init(self)

  self.route = route
  self.actor = false

  if not _initialized then _initGraphicValues() end

end

function ActorView:loadActor()
  local newactor = self.route.getControlledActor()
  if self.actor ~= newactor and newactor then
    self.actor = newactor
  end
  return self.actor
end

function ActorView:draw()
  local g = love.graphics
  local actor = self:loadActor()
  if not actor then return end
  local ath = actor:getATH()
  local arc = actor:getARC()
  local mec = actor:getMEC()
  local sector = self.route.getCurrentSector()

  g.push()

  FONT.set(_font)
  g.setColor(COLORS.NEUTRAL)

  g.translate(40, 40)
  g.print(_exptext:format(actor:getExp()), 0, 0)

  g.translate(0, 1.5*_font:getHeight())
  g.print(_statstext:format(ath, arc, mec))

  g.pop()

  g.push()

  local str = _depthtext:format(sector:getDepth())
  local w = _font:getWidth(str)
  g.translate(_width - 40 - w, 40)
  g.printf(str, 0, 0, w, "right")

  g.pop()
end

return ActorView
