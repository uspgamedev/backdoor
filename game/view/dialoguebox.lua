
local Class    = require "steaming.extra_libs.hump.class"
local VIEWDEFS = require 'view.definitions'
local ELEMENT  = require "steaming.classes.primitives.element"
local COLORS   = require 'domain.definitions.colors'
local FONT     = require 'view.helpers.font'

local _TILE_W = VIEWDEFS.TILE_W
local _TILE_H = VIEWDEFS.TILE_H
local _FX_MAGNITUDE = 6
local _FX_SPEED = 2.5
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

  g.push()
  g.translate(x, y)

  --Draw bg
  g.setColor(COLORS.HUD_BG)
  g.rectangle("fill", 0, 0, self.w, self.h)
  g.setColor(COLORS.NEUTRAL)
  g.setLineWidth(3)
  g.rectangle("line", 0, 0, self.w, self.h)

  --Draw text
  g.setColor(COLORS.NEUTRAL)
  _font:set()
  _font:setFilter("linear", "linear")
  g.print(self.text, 0 + 10, 0)

  g.pop()
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

  local fx_offset = math.sin(love.timer.getTime() * _FX_SPEED) * _FX_MAGNITUDE
  y = (self.i+.5)*_TILE_H - self.h/2 + self.y_offset + fx_offset

  return math.floor(x + .5), math.floor(y + .5)
end

function DialogueBox:getSize()
  return 1.5*_TILE_W - 2*self.x_margin, _TILE_H
end

return DialogueBox
