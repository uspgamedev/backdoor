
local VIEW_COLORS = require 'view.definitions.colors'

local Class     = require "steaming.extra_libs.hump.class"
local ELEMENT   = require "steaming.classes.primitives.element"

local InfoPanel = Class{
  __includes = { ELEMENT }
}

local _WIDTH = 2000
local _HEIGHT = 2000

function InfoPanel:init(position)

  ELEMENT.init(self)

  self.position = position:clone()

end

--function InfoPanel:update(dt)
--end

function InfoPanel:draw()
  local g = love.graphics -- luacheck: globals love
  g.push()
  g.setColor(VIEW_COLORS.DARK)
  g.rectangle('fill', self.position.x, self.position.y, _WIDTH, _HEIGHT)
  g.setColor(VIEW_COLORS.BRIGHT)
  g.setLineWidth(8)
  g.rectangle('line', self.position.x, self.position.y, _WIDTH, _HEIGHT)
  g.pop()
end

return InfoPanel

