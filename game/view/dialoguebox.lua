
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

  --Box attributes
  self.x_margin = _TILE_W/6
  self.y_offset = -_TILE_H/3
  self.max_width = 2*_TILE_W

  --Text attributes
  self.text_margin = 5
  self.text = self:parseText(body:getDialogue())

  --Dialogue box position attributes
  self.i = i
  self.j = j
  self.side = side

end

function DialogueBox:draw()
  local g = love.graphics
  local x, y = self:getPosition()
  local w, h = self:getSize()

  g.push()
  g.translate(x, y)

  --Draw bg
  g.setColor(COLORS.HUD_BG)
  g.rectangle("fill", 0, 0, w, h)
  g.setColor(COLORS.NEUTRAL)
  g.setLineWidth(3)
  g.rectangle("line", 0, 0, w, h)

  --Draw text
  g.setColor(COLORS.NEUTRAL)
  _font:set()
  for i, c in ipairs(self.text) do
    g.print(c.char, c.x, c.y)
  end

  g.pop()
end

function DialogueBox:setSide(side)
  self.side = side
end

function DialogueBox:getPosition()
  local x, y
  local w, h = self:getSize()

  if self.side == "right" then
    x = (self.j+1)*_TILE_W + self.x_margin
  elseif self.side == "left" then
    x = self.j*_TILE_W -self.x_margin - w
  else
    error("not a valid side for dialogue box")
  end

  local fx_offset = math.sin(love.timer.getTime() * _FX_SPEED) * _FX_MAGNITUDE
  y = (self.i+.5)*_TILE_H - h/2 + self.y_offset + fx_offset

  return math.floor(x + .5), math.floor(y + .5)
end

function DialogueBox:getSize()
  local max_x = 0
  for _, c in ipairs(self.text) do
    if max_x < c.x + _font:getWidth(c.char) then
      max_x = c.x + _font:getWidth(c.char)
    end
  end
  local w = math.min(max_x + self.text_margin, self.max_width)
  local h = self.text[#self.text].y + _font:getHeight()
  return w, h
end

function DialogueBox:parseText(text)
  local parsed = {}
  local x = self.text_margin
  local y = 0
  for i = 1, text:len() do
    local char = text:sub(i,i)
    local w = _font:getWidth(char)
    parsed[i] = {
      char = char,
      x = x,
      y = y,
    }
    x = x + w

    --Wrap words
    if x > self.max_width - 2*self.text_margin then
      y = y + _font:getHeight()
      x = self.text_margin
      --Find start of current word
      local j = i
      while j >= 1 do
        if parsed[j].char == " " then break end
        j = j - 1
      end
      if j == 0 then error("Word is too damn big") end
      --Fix position of every character
      for k = j+1, i do
        local w = _font:getWidth(parsed[k].char)
        parsed[k].x = x
        parsed[k].y = y
        x = x + w
      end
    end
  end

  return parsed
end

return DialogueBox
