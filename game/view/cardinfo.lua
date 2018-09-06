
local CARD  = require 'view.helpers.card'
local COLORS = require 'domain.definitions.colors'
local FONT = require 'view.helpers.font'
local vec2  = require 'cpml' .vec2

local _W

local CardInfo = Class{
  __includes = { ELEMENT }
}

function CardInfo:init(route)

  ELEMENT.init(self)

  self.route = route
  self.card = nil
  self.position = vec2()
  self.hide_desc = false
  self.title_font = FONT.get("TextBold", 20)
  self.text_font = FONT.get("Text", 20)

  _W = love.graphics.getDimensions()/3

end

function CardInfo:setCard(card)
  self.card = card
end

function CardInfo:setPosition(pos)
  self.position = pos
end

function CardInfo:show()
end

function CardInfo:hide()
end

function CardInfo:update(dt)

end

function CardInfo:draw()
  local alpha = 1
  if self.card == 'draw' then
    self.card = require 'view.helpers.newhand_card'
  end
  local g = love.graphics
  local cr, cg, cb = unpack(COLORS.NEUTRAL)
  local player_actor = self.route.getPlayerActor()

  g.push()

  g.translate(self.position:unpack())
  g.setColor(cr, cg, cb, alpha)

  self.title_font:setLineHeight(1.5)
  self.title_font.set()
  g.printf(self.card:getName(), 0, 0, _W)

  g.translate(0, self.title_font:getHeight())

  self.text_font.set()
  local desc = self.card:getEffect(player_actor)
  if not self.hide_desc then
    desc = desc .. "\n\n---"
    desc = desc .. '\n\n' .. (self.card:getDescription() or "[No description]")
  end
  desc = desc:gsub("([^\n])[\n]([^\n])", "%1 %2")
  desc = desc:gsub("\n\n", "\n")
  g.printf(desc, 0, 0, _W)

  g.pop()
end

return CardInfo

