
local COLORS = require 'domain.definitions.colors'
local FONT   = require 'view.helpers.font'
local Class  = require "steaming.extra_libs.hump.class"
local Color   = require 'common.color'

local Text = Class()

function Text:init(text, fontname, size, effects)
  self.text = text
  self.font = FONT.get(fontname, size)
  effects = effects or {}
  -- color can be a color name OR a color!
  self.color = COLORS[effects.color] or effects.color or COLORS.NEUTRAL
  assert(self.color, "Invalid color!")
  -- alpha
  self.alpha = effects.alpha or 1
  -- boolean
  self.dropshadow = not not effects.dropshadow
  -- alignment
  self.width = effects.width
  self.align = effects.align or "left"
end

function Text:hasText()
  return not not self.text
end

function Text:setText(text)
  self.text = text
end

function Text:setColor(color)
  self.color = color
  assert(self.color, "Invalid color!")
end

function Text:getAlpha()
  return self.alpha
end

function Text:setAlpha(value)
  self.alpha = value or 1
end

function Text:setDropShadow(enable)
  self.dropshadow = not not enable
end

function Text:getHeight()
  return self.font:getHeight()
end

function Text:setWidth(w)
  -- set nil or false to disable box!
  self.width = w
end

function Text:getTextWidth()
  return self.font:getWidth(self.text)
end

function Text:setAlign(align)
  self.align = align
end

function Text:draw(x, y)
  local g = love.graphics
  local oldfont = g.getFont()
  local oldcolor = { g.getColor() }
  local width = self.width
  local trans = Color:new{1,1,1,self.alpha}
  self.font:set()
  -- dropshadow
  if self.dropshadow then
    g.setColor(COLORS.DARKER * trans)
    if width then
      g.printf(self.text, x+1, y+1, width, self.align)
    else
      g.print(self.text, x+1, y+1)
    end
  end
  -- draw text!
  g.setColor(self.color * trans)
  if width then
    g.printf(self.text, x, y, width, self.align)
  else
    g.print(self.text, x, y)
  end
  g.setColor(oldcolor)
  return g.setFont(oldfont)
end

return Text
