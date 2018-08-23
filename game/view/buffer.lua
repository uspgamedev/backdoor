
local vec2    = require 'cpml' .vec2
local TEXTURE = require 'view.helpers.texture'
local FONT    = require 'view.helpers.font'
local DEFS    = require 'view.definitions'

local BufferView = Class{
  __includes = { ELEMENT }
}

function BufferView:init(route)
  ELEMENT.init(self)
  self.sprite = TEXTURE.get('buffer')
  self.sprite:setFilter("linear", "linear", 1)
  self.clr = {1, 1, 1, 1}
  self.side = 'left'
  self.font = FONT.get("Text", 24)
  self.amount = 0
end

function BufferView.newFrontBufferView(route)
  local bufview = BufferView(route)
  bufview.clr = {1, 1, 1, 1}
  bufview.side = 'left'
  return bufview
end

function BufferView.newBackBufferView(route)
  local bufview = BufferView(route)
  bufview.clr = {1, 0.5, 0.5, 1}
  bufview.side = 'right'
  return bufview
end

function BufferView:draw()
  local g = love.graphics
  local W,H = DEFS.VIEWPORT_DIMENSIONS()
  local margin = 48
  local scale = 0.3
  local text
  local textoffx
  local align
  local pos, offset
  if self.side == 'left' then
    pos = vec2(margin, H - margin)
    offset = vec2(0, self.sprite:getHeight())
    text = string.format("x %d", self.amount)
    align = 'right'
    textoffx = 0
  elseif self.side == 'right' then
    pos = vec2(W - margin, H - margin)
    offset = vec2(self.sprite:getDimensions())
    text = string.format("%d x", self.amount)
    align = 'left'
    textoffx = 1
  else
    return error("invalid buffer view side position")
  end
  local limit = self.sprite:getWidth() * scale + self.font:getWidth(text)
              + margin/3
  self.font:set()
  g.push()
  g.translate(pos.x, pos.y)
  g.scale(scale, scale)
  g.setColor(self.clr)
  self.sprite:draw(0, 0, 0, 1, 1, offset.x, offset.y)
  g.printf(text, 0, 0, limit, align, 0, 1/scale, 1/scale,
           textoffx * limit, self.font:getHeight())
  g.pop()
end

return BufferView

