
local DB = require 'database'
local COLORS = require 'domain.definitions.colors'

local ActorView = Class{
  __includes = { ELEMENT }
}

local _initialized = false
local WIDTH, HEIGHT
local EXPTEXT

local function _initGraphicValues()
  WIDTH, HEIGHT = love.graphics.getDimensions()
  FONT = love.graphics.newFont(DB.loadFontPath("Saira"), 24)
  EXPTEXT = "EXP: %d"
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
  g.push()
  g.setFont(FONT)
  g.setColor(COLORS.NEUTRAL)
  g.translate(40, 40)
  g.print(EXPTEXT:format(actor:getExp()), 0, 0)
  g.pop()
end

return ActorView

