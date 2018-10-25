local vec2    = require 'cpml' .vec2
local COLORS  = require 'domain.definitions.colors'
local FONT    = require 'view.helpers.font'
local RES     = require 'resources'

local Button = Class{
  __includes = { ELEMENT }
}

function Button:init(x, y)
    ELEMENT.init(self)
    self:setSubtype("control_hints")

    self.pos = vec2(x, y)

    self.image = RES.loadTexture("button-draw_hand")
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
    local g = love.graphics
    local x, y, scale = self.pos.x, self.pos.y, .4
    g.setColor(1,1,1)
    g.draw(self.image, x, y, nil, scale)

    --Draw "draw hand" text
    local text = "draw hand"
    local gap = 10
    local text_y = y - 5
    local text_x = x + self.image:getWidth()*scale + gap
    self.text_font:set()
    g.setColor(COLORS.BLACK)
    g.print(text, text_x + 2, text_y + 2)
    g.setColor(COLORS.NEUTRAL)
    g.print(text, text_x, text_y)

    --Draw cost of consumption
    text_y = text_y + 22
    text = "-"..self.cost.." PP"
    self.text_font2:set()
    g.setColor(COLORS.BLACK)
    g.print(text, text_x + 1, text_y + 1)
    g.setColor(COLORS.PP)
    g.print(text, text_x, text_y)
end

return Button
