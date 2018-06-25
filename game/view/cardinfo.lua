
local CARD  = require 'view.helpers.card'
local vec2  = require 'cpml' .vec2

local _W

local CardInfo = Class{
  __includes = { ELEMENT }
}

function CardInfo:init()

  ELEMENT.init(self)

  self.card = nil

  _W = love.graphics.getDimensions()/3

end

function CardInfo:set(card)
  self.card = card
end

function CardInfo:draw()
  CARD.drawInfo(self.card, 20, 40, _W, 1, nil, true)
end

return CardInfo

