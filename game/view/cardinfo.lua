
-- luacheck: globals love

local Color     = require 'common.color'
local COLORS    = require 'domain.definitions.colors'
local FONT      = require 'view.helpers.font'
local vec2      = require 'cpml' .vec2
local Class     = require "steaming.extra_libs.hump.class"
local ELEMENT   = require "steaming.classes.primitives.element"
local VIEWDEFS  = require 'view.definitions'

local _SCALE = 4
local _MW = 16
local _MH = 12
local _PW = 16
local _PH = 12

local CardInfo = Class{
  __includes = { ELEMENT }
}

function CardInfo:init(route)

  ELEMENT.init(self)

  local w, h = VIEWDEFS.VIEWPORT_DIMENSIONS()
  self.route = route
  self.card = nil
  self.position = vec2(w * 0.02, h * 0.1)
  self.hide_desc = true
  self.title_font = FONT.get("TextBold", 24)
  self.text_font = FONT.get("Text", 18)
  self.alpha = 1
  self.invisible = true
  self.side = 'right'

  --Oscilating effect
  self.oscilate = 0
  self.oscilate_magnitude = 4
  self.oscilate_speed = 6

end

function CardInfo:setCard(card)
  self.card = card
end

function CardInfo:show()
  self.invisible = false
  self.alpha = 0
end

function CardInfo:hide()
  self.invisible = true
end

function CardInfo:isVisible()
  return not self.invisible
end

function CardInfo:update(dt)
  if not self.invisible then
    self.oscilate = self.oscilate + self.oscilate_speed * dt
    self.alpha = self.alpha + (1 - self.alpha) * dt * 20
  end
end

function CardInfo:draw()
  local alpha = self.alpha
  local g = love.graphics
  local cr, cg, cb = unpack(COLORS.BLACK)
  local player_actor = self.route.getPlayerActor()
  local width = VIEWDEFS.CARD_W * _SCALE
  local height = VIEWDEFS.CARD_H * _SCALE

  local desc = self.card:getEffect(player_actor)
  if not self.hide_desc then
    desc = desc .. "\n\n---"
    desc = desc .. '\n\n' .. (self.card:getDescription() or "[No description]")
  end
  desc = desc:gsub("([^\n])[\n]([^\n])", "%1 %2")
  desc = desc:gsub("\n\n", "\n")

  self.text_font:setLineHeight(1)

  g.push()
  g.translate(self.position:unpack())
  local offset = math.sin(self.oscilate)*self.oscilate_magnitude
  g.translate(0, offset)

  local boxw = width
  local boxh = height
  local corner = 12 * _SCALE
  local box = {
    0, corner,
    corner, 0,
    boxw, 0,
    boxw, boxh - corner,
    boxw - corner, boxh,
    0, boxh
  }

  -- Draw card-shaped panel
  g.push()
  local shadow = 8
  g.translate(shadow, 2*shadow - offset)
  g.setColor(COLORS[self.card:getRelatedAttr()] * Color:new{.4, .4, .4, alpha/2})
  g.polygon('fill', box)
  g.translate(-shadow, -(2*shadow - offset))
  g.setColor(COLORS[self.card:getRelatedAttr()] * Color:new{1, 1, 1, alpha})
  g.polygon('fill', box)
  g.pop()

  g.translate(_MW, _MH)

  -- Draw icon
  local inner_corner = corner
  local left, right = 0, width - (_MW+_PW)*2
  local top, bottom = 0, (height - (_MH+_PH)*2) / 2
  g.push()
  g.translate(_PW, _PH)
  g.setColor(COLORS.DARK)
  g.polygon('fill', left, top + inner_corner,
                    left + inner_corner, top,
                    right - inner_corner, top,
                    right, top + inner_corner,
                    right, bottom - inner_corner,
                    right - inner_corner, bottom,
                    left + inner_corner, bottom,
                    left, bottom - inner_corner)
  g.pop()

  -- Draw description
  g.translate(0, height / 2)

  g.setColor(cr, cg, cb, alpha)

  self.title_font:setLineHeight(1.5)
  self.title_font.set()
  g.printf(self.card:getName(), 0, 0, width - _MW*2, 'center')

  g.translate(0, 2 * self.title_font:getHeight())

  self.text_font.set()
  g.printf(desc, 0, 0, width - _MW*2)

  g.pop()
end

return CardInfo
