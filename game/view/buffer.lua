
local vec2    = require 'cpml' .vec2
local TEXTURE = require 'view.helpers.texture'
local FONT    = require 'view.helpers.font'
local DEFS    = require 'view.definitions'

local _SCALE = 0.3
local _MX = 48
local _MY = 32

local BufferView = Class{
  __includes = { ELEMENT }
}

function BufferView:init(route)
  ELEMENT.init(self)
  self.sprite = TEXTURE.get('buffer')
  self.sprite:setFilter("linear", "linear", 1)
  self.clr = {1, 1, 1, 1}
  self.side = 'front'
  self.font = FONT.get("Text", 24)
  self.amount = 0
  self.route = route

  -- define later
  self.pos = nil
  self.offset = nil
  self.align = nil
  self.format = nil
  self.textoffx = nil
end

function BufferView.newFrontBufferView(route)
  local bufview = BufferView(route)
  bufview.clr = {1, 1, 1, 1}
  bufview.side = 'front'
  bufview:calculatePosition()
  return bufview
end

function BufferView.newBackBufferView(route)
  local bufview = BufferView(route)
  bufview.clr = {1, 0.5, 0.5, 1}
  bufview.side = 'back'
  bufview:calculatePosition()
  return bufview
end

function BufferView:calculatePosition()
  local W,H = DEFS.VIEWPORT_DIMENSIONS()
  if self.side == 'front' then
    self.pos = vec2(_MX, H - _MY)
    self.offset = vec2(0, self.sprite:getHeight())
    self.format = "x %d"
    self.align = 'right'
    self.textoffx = 0
  elseif self.side == 'back' then
    self.pos = vec2(W - _MX, H - _MY)
    self.offset = vec2(self.sprite:getDimensions())
    self.format = "%d x"
    self.align = 'left'
    self.textoffx = 1
  else
    return error("invalid buffer view side position")
  end
end

function BufferView:getPoint()
  return self.pos + vec2(self.sprite:getWidth(), -self.offset.y)/2*_SCALE
end

function BufferView:update(dt)
  local actor = self.route.getControlledActor()
  if self.side == 'front' then
    self.amount = actor:getBufferSize()
  elseif self.side == 'back' then
    self.amount = actor:getBackBufferSize()
  end
end

function BufferView:draw()
  local g = love.graphics
  local text = self.format:format(self.amount)
  local limit = self.sprite:getWidth() * _SCALE + self.font:getWidth(text)
              + _MX/3
  self.font:set()
  g.push()
  g.translate(self.pos.x, self.pos.y)
  g.scale(_SCALE, _SCALE)
  g.setColor(self.clr)
  self.sprite:draw(0, 0, 0, 1, 1, self.offset.x, self.offset.y)
  g.printf(text, 0, 0, limit, self.align, 0, 1/_SCALE, 1/_SCALE,
           self.textoffx * limit, self.font:getHeight())
  g.pop()
end

return BufferView

