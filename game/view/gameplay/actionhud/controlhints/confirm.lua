local COLORS      = require 'domain.definitions.colors'
local FONT        = require 'view.helpers.font'
local RES         = require 'resources'
local CONTROLHINT = require 'view.gameplay.actionhud.controlhints'
local Class       = require "steaming.extra_libs.hump.class"

local Button = Class{
  __includes = { CONTROLHINT }
}

function Button:init(x, y)
    CONTROLHINT.init(self, x, y)

    self.image = RES.loadTexture("button-key-confirm")
    self.image:setFilter("linear")
    self.text_font = FONT.get("Text", 20)
    self.text_font2 = FONT.get("Text", 16)
end

function Button:setCost(v)
    self.cost = v
end

function Button:draw()
    local g = love.graphics
    local x, y, scale = self.pos.x, self.pos.y, .4
    g.setColor(1,1,1,self.alpha)
    g.draw(self.image, x, y, nil, scale)

    local text = "Confirm/Interact"
    local gap = 4
    local text_y = y + self.image:getHeight()*scale/2 - self.text_font:getHeight()/2
    local text_x = x + self.image:getWidth()*scale + gap
    self.text_font:set()
    local c = COLORS.BLACK
    g.setColor(c[1], c[2], c[3], self.alpha)
    g.print(text, text_x + 2, text_y + 2)
    c = COLORS.NEUTRAL
    g.setColor(c[1], c[2], c[3], self.alpha)
    g.print(text, text_x, text_y)
end

return Button
