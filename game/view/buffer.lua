
local vec2    = require 'cpml' .vec2
local TEXTURE = require 'view.helpers.texture'
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
end

function BufferView.newFrontBufferView(route)
  local bufview = BufferView(route)
  bufview.clr = {1, 1, 1, 1}
  bufview.side = 'left'
  return bufview
end

function BufferView.newBackBufferView(route)
  local bufview = BufferView(route)
  bufview.clr = {1, 1, 0.5, 1}
  bufview.side = 'right'
  return bufview
end

function BufferView:draw()
  local g = love.graphics
  local W,H = DEFS.VIEWPORT_DIMENSIONS()
  local margin = 48
  local scale = 0.5
  local pos
  if self.side == 'left' then
    pos = vec2(margin, H - self.sprite:getHeight() * scale - margin)
  elseif self.side == 'right' then
    pos = vec2(W - self.sprite:getWidth() * scale - margin,
               H - self.sprite:getHeight() * scale - margin)
  else
    return error("invalid buffer view side position")
  end
  g.setColor(self.clr)
  self.sprite:draw(pos.x, pos.y, 0, scale, scale)
end

return BufferView

