local vec2    = require 'cpml' .vec2
local Button  = require 'view.controlhints.newhand'
local TEXTURE = require 'view.helpers.texture'
local FONT    = require 'view.helpers.font'
local DEFS    = require 'view.definitions'
local COLORS  = require 'domain.definitions.colors'
local Class   = require "steaming.extra_libs.hump.class"
local ELEMENT = require "steaming.classes.primitives.element"

local _SCALE = 0.75
local _MX = 48
local _MY = 32
local _W_OFFSET = 2
local _H_OFFSET = -1
local _GRADIENT_FILTER = .3

local BufferView = Class{
  __includes = { ELEMENT }
}

function BufferView:init(route)
  ELEMENT.init(self)
  self.route = route

  self.sprite = TEXTURE.get('card-base')
  self.sprite:setFilter("linear", "linear", 1)
  self.clr = {1, 1, 1, 1}
  self.side = 'front'
  self.font = FONT.get("Text", 24)
  self.amount = 0

  -- define later
  self.pos = nil
  self.format = nil

  -- hint button
  self.button = Button(-5, -115)

end

function BufferView.newFrontBufferView(route)
  local bufview = BufferView(route)
  bufview.clr = {.8, .8, .8, 1}
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
    self.pos = vec2(_MX, H - _MY - self.sprite:getHeight())
    self.format = "x %d"
  elseif self.side == 'back' then
    self.pos = vec2(W - _MX - self.sprite:getWidth(), H - _MY - self.sprite:getHeight())
    self.format = "%d x"
  else
    return error("invalid buffer view side position")
  end
end

function BufferView:getPoint()
  local size = self.amount
  if self.side == 'front' then
    return self.pos + vec2(size * _W_OFFSET + self.sprite:getWidth()/2*_SCALE,
                           size * _H_OFFSET + self.sprite:getHeight()/2*_SCALE)
  elseif self.side == 'back' then
    return self.pos + vec2(size * -_W_OFFSET + self.sprite:getWidth()/2*_SCALE,
                           size * _H_OFFSET + self.sprite:getHeight()/2*_SCALE)
  end
end

function BufferView:flashFor(duration, color)
  --pass
end

function BufferView:update(dt)
  local actor = self.route.getControlledActor()
  if self.side == 'front' then
    self.button:setCost(actor:getBody():getConsumption())
    self.button:update(dt)
    self.amount = actor:getBufferSize()
  elseif self.side == 'back' then
    self.amount = actor:getBackBufferSize()
  end
end

function BufferView:draw()
  local g = love.graphics
  local text = self.format:format(self.amount)

  g.push()
  g.translate(self.pos.x, self.pos.y)

  local finish, step
  if self.side == "front" then
    --Draw button ontop of front buffer
    self.button:draw()

    finish, step = self.amount - 1, 1
  elseif self.side == "back" then
    finish, step = -self.amount + 1, -1
  else
    error("Not a valid side for bufferview: "..self.side)
  end

  --Draw buffer "background"
  g.setColor(self.clr[1], self.clr[2], self.clr[3], self.clr[3]*.1)
  self.sprite:draw(0, 0, 0, _SCALE, _SCALE)

  --Draw buffer
  local grd
  for i = 0, finish, step do
    grd = (i == finish) and 1 or _GRADIENT_FILTER
    g.setColor(self.clr[1]*grd, self.clr[2]*grd, self.clr[3]*grd, self.clr[4])
    self.sprite:draw(i*_W_OFFSET, -step*i*_H_OFFSET, 0, _SCALE, _SCALE)
  end
  --Draw buffer size
  local card_w, card_h = self.sprite:getWidth()*_SCALE, self.sprite:getHeight()*_SCALE
  local text_w, text_h = self.font:getWidth(text), self.font:getHeight()
  grd = _GRADIENT_FILTER
  self.font:set()
  g.setColor(self.clr[1]*grd, self.clr[2]*grd, self.clr[3]*grd, self.clr[4])
  g.print(text, finish*_W_OFFSET + card_w/2 - text_w/2,
                -step*finish*_H_OFFSET + card_h/2 - text_h/2)


  g.pop()
end

return BufferView
