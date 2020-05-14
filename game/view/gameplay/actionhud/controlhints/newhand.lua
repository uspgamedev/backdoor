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

    self.image = RES.loadTexture("button-key-draw_hand")
    self.image:setFilter("linear")
    self.text_font = FONT.get("Text", 20)
    self.text_font2 = FONT.get("Text", 16)

    --How much PP it cost to buy a new hand
    self.cost = "~"
end

function Button:setCost(v)
    self.cost = v
end

function Button:draw()
    local g = love.graphics -- luacheck: globals love
    local x, y, scale = self.pos.x, self.pos.y, .4
    g.setColor(1,1,1,self.alpha)
    g.draw(self.image, x, y, nil, scale)

    --Draw "draw hand" text
    local text = "draw hand"
    local gap = 10
    local text_y = y - 5
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
