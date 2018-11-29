local COLORS      = require 'domain.definitions.colors'
local FONT        = require 'view.helpers.font'
local RES         = require 'resources'
local CONTROLHINT = require 'view.controlhints.controlhint'
local Class       = require "steaming.extra_libs.hump.class"

local Button = Class{
  __includes = { CONTROLHINT }
}

function Button:init(x, y, side)
    CONTROLHINT.init(self, x, y)

    if side == "left" then
      self.image = RES.loadTexture("button-prev_hand_cursor")
      self.image:setFilter("linear")
    elseif side == "right" then
      self.image = RES.loadTexture("button-next_hand_cursor")
      self.image:setFilter("linear")
    else
      error("not a valid side")
    end

    --Scale of image
    self.image_sx = .5
    self.image_sy = .7
end

function Button:setPos(x, y)
    self.pos.x = x
    self.pos.y = y
end

function Button:getWidth()
    return self.image:getWidth()*self.image_sx
end

function Button:getHeight()
    return self.image:getHeight()*self.image_sy
end

function Button:draw()
  local g = love.graphics
  local x, y = self.pos.x, self.pos.y
  g.setColor(1,1,1,self.alpha)
  g.draw(self.image, x, y, nil, self.image_sx, self.image_sy)
end

return Button
