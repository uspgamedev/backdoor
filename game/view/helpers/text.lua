
local COLORS = require 'domain.definitions.colors'
local FONT = require 'view.helpers.font'

local Text = Class()

function Text:init(text, fontname, size, effects)
  self.text = text
  self.font = FONT.get(fontname, size)
  effects = effects or {}
  -- color can be a color name OR a color!
  self.color = COLORS[effects.color] or effects.color or COLORS.NEUTRAL
  assert(self.color, "Invalid color!")
  -- boolean
  self.dropshadow = not not effects.dropshadow
  -- alignment
  self.width = effects.width
  self.align = effects.align or "left"
end

function Text:setText(text)
  self.text = text
end

function Text:setColor(color)
  self.color = COLORS[effects.color] or effects.color or COLORS.NEUTRAL
  assert(self.color, "Invalid color!")
end

function Text:setDropShadow(enable)
  self.dropshadow = not not enable
end

function Text:setWidth(w)
  -- set nil or false to disable box!
  self.width = w
end

function Text:setAlign(align)
  self.align = align
end

function Text:draw(x, y)
  local g = love.graphics
  local oldfont = g.getFont()
  local oldcolor = { g.getColor() }
  local width = self.width
  self.font:set()
  -- dropshadow
  if self.dropshadow then
    g.setColor(COLORS.DARKER)
    if width then
      g.printf(self.text, x+1, y+1, width, self.align)
    else
      g.print(self.text, x+1, y+1)
    end
  end
  -- draw text!
  g.setColor(self.color)
  if width then
    g.printf(self.text, x, y, width, self.align)
  else
    g.print(self.text, x, y)
  end
  g.setColor(oldcolor)
  return g.setFont(oldfont)
end

return Text
