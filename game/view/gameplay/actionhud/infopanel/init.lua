
local VIEW_COLORS = require 'view.definitions.colors'

local Class     = require "steaming.extra_libs.hump.class"
local ELEMENT   = require "steaming.classes.primitives.element"

local InfoPanel = Class{
  __includes = { ELEMENT }
}

local _WIDTH = 200
local _HEADER_HEIGHT = 40
local _HEIGHT = 200

function InfoPanel:init(position)

  ELEMENT.init(self)

  self.position = position:clone()

end

--function InfoPanel:update(dt)
--end

function InfoPanel:draw()
  local g = love.graphics -- luacheck: globals love
  g.push()
  g.translate(self.position:unpack())
  g.setColor(VIEW_COLORS.BRIGHT)
  g.rectangle('fill', -2, 0, _WIDTH+4, _HEADER_HEIGHT+4, 4, 4)
  g.setColor(VIEW_COLORS.DARK)
  g.print("Information", 16, 8)
  g.rectangle('fill', 0, _HEADER_HEIGHT, _WIDTH, _HEIGHT, 4, 4)
  g.setColor(VIEW_COLORS.BRIGHT)
  g.setLineWidth(4)
  g.rectangle('line', 0, _HEADER_HEIGHT, _WIDTH, _HEIGHT, 4, 4)
  g.print("This is a test", 16, _HEADER_HEIGHT + 16)
  g.pop()
end

return InfoPanel

