
local Class    = require "steaming.extra_libs.hump.class"
local VIEWDEFS = require 'view.definitions'
local ELEMENT  = require "steaming.classes.primitives.element"
local COLORS   = require 'domain.definitions.colors'
local FONT     = require 'view.helpers.font'

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H
local _font = FONT.get('Text', 20)

-- Class

local DialogueBox = Class{
  __includes = { ELEMENT }
}

--[[ PUBLIC METHODS ]]--

function DialogueBox:init(body, i, j, side)
  ELEMENT.init(self)

  self.x_margin = _TILE_W/6
  self.y_offset = -_TILE_H/3
  self.text = body:getDialogue()

  self.i = i
  self.j = j
  self.side = side
  self.w, self.h = self:getSize()

end

function DialogueBox:draw()
  local g = love.graphics
  local x, y = self:getPosition()
  --Draw bg
  g.setColor(COLORS.HUD_BG)
  g.rectangle("fill", x, y, self.w, self.h)
  g.setColor(COLORS.NEUTRAL)
  g.setLineWidth(3)
  g.rectangle("line", x, y, self.w, self.h)

  --Draw text
  g.setColor(COLORS.NEUTRAL)
  _font:set()
  g.print(self.text, x + 10, y)
end

function DialogueBox:setSide(side)
  self.side = side
end

function DialogueBox:getPosition()
  local x, y

  if self.side == "right" then
    x = (self.j+1)*_TILE_W + self.x_margin
  elseif self.side == "left" then
    x = (self.j-.5)*_TILE_W - self.x_margin - self.w/2
  else
    error("not a valid side for dialogue box")
  end

  y = (self.i+.5)*_TILE_H - self.h/2 + self.y_offset

  return x, y
end

function DialogueBox:getSize()
  return 1.5*_TILE_W - 2*self.x_margin, _TILE_H
end

return DialogueBox
